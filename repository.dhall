let
  Log =
    { accesslog:
        { disabled: Bool -- true
        }
    , level: Text -- debug
    , formatter: Text -- text
    , fields:
        { service: Text -- registry
        , environment: Text -- staging
        }
    , hooks:
        [ { type: Text -- mail
          , disabled: Bool -- true
          , levels: [Text] -- panic
          options:
            { smtp:
              { addr: Text -- mail.example.com:25
              , username: Text -- mailuser
              , password: Text -- password
              , insecure: Bool -- true
              }
            , from: Text -- sender@example.com
            , to: [ Text ] -- errors@example.com
            }
          }
        ]
    }

let Storage =
  { filesystem:
      { rootdirectory: Text -- /var/lib/registry
      ,  maxthreads: Natural -- 100
      }
  , azure:
    { accountname: Text -- accountname
    ,  accountkey: Text -- base64encodedaccountkey
    ,  container: Text -- containername
    }
  , gcs:
    { bucket: Text -- bucketname
    , keyfile: Text -- /path/to/keyfile
    , credentials:
      { type: Text -- service_account
      ,  project_id: Text -- project_id_string
      ,  private_key_id: Text -- private_key_id_string
      ,  private_key: Text -- private_key_string
      ,  client_email: Text -- client@example.com
      ,  client_id: Text -- client_id_string
      ,  auth_uri: Text -- http://example.com/auth_uri
      ,  token_uri: Text -- http://example.com/token_uri
      ,  auth_provider_x509_cert_url: Text -- http://example.com/provider_cert_url
      ,  client_x509_cert_url: Text -- http://example.com/client_cert_url
      }
    , rootdirectory: Text -- /gcs/object/name/prefix
    , chunksize: Natural -- 5242880
    }
  , s3:
    { accesskey: Text -- awsaccesskey
    , secretkey: Text -- awssecretkey
    , region: Text -- us-west-1
    , regionendpoint: Text -- http://myobjects.local
    , bucket: Text -- bucketname
    , encrypt: Bool -- true
    , keyid: Text -- mykeyid
    , secure: Bool -- true
    , v4auth: Bool -- true
    , chunksize: Natural -- 5242880
    , multipartcopychunksize: Natural -- 33554432
    , multipartcopymaxconcurrency: Natural -- 100
    , multipartcopythresholdsize: Natural -- 33554432
    , rootdirectory: Text -- /s3/object/name/prefix
    }
  , swift:
    { username: Text -- username
    , password: Text -- password
    , authurl: Text -- https://storage.myprovider.com/auth/v1.0 or https://storage.myprovider.com/v2.0 or https://storage.myprovider.com/v3/auth
    , tenant: Text -- tenantname
    , tenantid: Text -- tenantid
    , domain: Text -- domain name for Openstack Identity v3 API
    , domainid: Text -- domain id for Openstack Identity v3 API
    , insecureskipverify: Bool -- true
    , region: Text -- fr
    , container: Text -- containername
    , rootdirectory: Text -- /swift/object/name/prefix
    }
  , oss:
    { accesskeyid: Text -- accesskeyid
    , accesskeysecret: Text -- accesskeysecret
    , region: Text -- OSS region name
    , endpoint: Optional Text -- optional endpoints
    , internal: Optional Text -- optional internal endpoint
    , bucket: Text -- OSS bucket
    , encrypt: Optional Text -- optional data encryption setting
    , secure: Optional Text -- optional ssl setting
    , chunksize: Optional Text -- optional size valye
    , rootdirectory: Optional Text -- optional root directory
    }
  , inmemory:  {} --# This driver takes no parameters
  , delete:
    { enabled: Bool -- false
    }
  , redirect:
    { disable: Bool -- false
    }
  , cache:
    { blobdescriptor: Text -- redis
    }
  , maintenance:
    { uploadpurging:
      { enabled: Bool -- true
      , age: Text -- 168h
      , interval: Text -- 24h
      , dryrun: Bool -- false
      }
    , readonly:
      { enabled: Bool -- false
      }
    }
  }

let Auth : Type =
  { silly:
    { realm: Text -- silly-realm
    , service: Text -- silly-service
    }
  , token:
    { autoredirect: Bool --  true
    , realm: Text -- token-realm
    , service: Text -- token-service
    , issuer: Text -- registry-token-issuer
    , rootcertbundle: Text -- /root/certs/bundle
    }
  , htpasswd:
    { realm: Text -- basic-realm
    , path: Text -- /path/to/htpasswd
    }
  }

let M : Type =
  { name: Text -- ARegistryMiddleware
  , options: { foo: bar }
  }

let MCloudfront : Type =
  { name: Text -- cloudfront
  , options:
    { baseurl: Text -- https://my.cloudfronted.domain.com/
    , privatekey: Text -- /path/to/pem
    , keypairid: Text -- cloudfrontkeypairid
    , duration: Text -- 3000s
    , ipfilteredby: Text -- awsregion
    , awsregion: Text -- us-east-1, use-east-2
    , updatefrenquency: Text -- 12h
    , iprangesurl: Text -- https://ip-ranges.amazonaws.com/ip-ranges.json
    }
  }

let MRedirect =
  { name: Text  -- redirect
  , options:
    { baseurl: Text  -- https://example.com/
    }
  }

let Middleware : Type =
  { registry: [ M ]
  , repository: [ M ]
  , storage: [ MCloudfront ]
  -- , storage: [ MRedirect ]
  }

let Reporting : Type =
  { bugsnag:
    { apikey: Text  -- bugsnagapikey
    , releasestage: Text  -- bugsnagreleasestage
    , endpoint: Text  -- bugsnagendpoint
    }
  , newrelic:
    { licensekey: Text -- newreliclicensekey
    , name: Text -- newrelicname
    , verbose: Bool -- true
    }
  }

let Http : Type =
  { addr: Text -- localhost:5000
  , prefix: Text -- /my/nested/registry/
  , host: Text -- https://myregistryaddress.org:5000
  , secret: Text -- asecretforlocaldevelopment
  , relativeurls: Bool -- false
  , draintimeout: Text -- 60s
  , tls:
    { certificate: Text -- /path/to/x509/public
    , key: Text -- /path/to/x509/private
    , clientcas:
        [ Text ] -- /path/to/ca.pem ,/path/to/another/ca.pem
    , letsencrypt:
      { cachefile: Text -- /path/to/cache-file
      , email: Text -- emailused@letsencrypt.com
      , hosts: Text -- [myregistryaddress.org]
      }
    }
  , debug:
    { addr: Text -- localhost:5001
    , prometheus:
      { enabled: Bool -- true
      , path: Text -- /metrics
      }
    }
  , headers:
    { X-Content-Type-Options: Text -- [nosniff]
    }
  , http2:
    { disabled: Bool -- false
    }
  }

let Notifications :  Type =
{ events:
  { includereferences: Bool -- true
  }
, endpoints:
    [
      { name: Text -- alistener
      , disabled: Bool -- false
      , url: Text -- https://my.listener.com/event
      , headers: Text -- <http.Header>
      , timeout: Text -- 1s
      , threshold: Natural -- 10
      , backoff: Text -- 1s
      , ignoredmediatypes:
        [ Text ] -- [application/octet-stream ]
      , ignore:
        { mediatypes:
        [ Text ] -- [application/octet-stream ]
        , actions:
          [ Text ] -- [ pull ]
        }
      }
    ]
}

let Redis : Type  =
  { addr: Text -- localhost:6379
  , password: Text -- asecret
  , db: Natural -- 0
  , dialtimeout: Text -- 10ms
  , readtimeout: Text -- 10ms
  , writetimeout: Text -- 10ms
  , pool:
    { maxidle: Natural -- 16
    , maxactive: Natural -- 64
    , idletimeout: Text -- 300s
    }
  }

let Health : Type =
  { storagedriver:
    { enabled: Bool -- true
    , interval: Text -- 10s
    , threshold: Natural -- 3
    }
  , file:
    [ { file: Text -- /path/to/checked/file
      , interval: Text -- 10s
      }
    ]
  , http:
    [ { uri: Text -- http://server.to.check/must/return/200
      , headers:
        { Authorization: Text -- [Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==]
        }
      , statuscode: Natural --  200
      , timeout: Text -- 3s
      , interval: Text -- 10s
      , threshold: Natural -- 3
      }
    ]
  , tcp:
    [ { addr: Text -- redis-server.domain.com:6379
      , timeout: Text -- 3s
      , interval: Text -- 10s
      , threshold: Natural --  3
      }
    ]
  }

let Proxy : Type =
  { remoteurl: Text -- https://registry-1.docker.io
  , username: Text -- [username]
  , password: Text -- [password]
  }

let Compatibility : Type =
  { schema1:
    { signingkeyfile: Text -- /etc/registry/key.json
    , enabled: Bool -- true
    }
  }

let Validation : Type =
  { manifests:
    { urls:
      { allow:
          [ Text ] -- ^https?://([^/]+\.)*example\.com/
      , deny:
          [ Text ] -- ^https?://www\.example\.com/
      }
    }
  }

let Repository : Type =
  { version : "0.1"
  , log : Log
  , storage : Storage
  , auth: Auth
  , middleware: Middleware
  , reporting: Reporting
  , http: Http
  , notifications: Notifications
  , redis: Redis
  , health: Health
  , proxy: Proxy
  , compatibility: Compatibility
  , validation: Validation
  }

in
  Repository
