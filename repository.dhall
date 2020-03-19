let JSON = https://prelude.dhall-lang.org/v11.1.0/JSON/package.dhall
let Object = [ { mapKey : Text, mapValue: JSON } ]

let
  Log =
    { accesslog:
        { disabled: Bool -- true
        }
    , level: Optional Text -- error, warn, info, and debug. The default is info.
    , formatter: Optional Text -- text, json, and logstash
    , fields:
        Optional
        [ { mapKey: Text, mapValue: Text } ]
    , hooks:
        [ { type: Text -- mail
          , disabled: Bool -- true
          , levels: [Text] -- panic
          , options: Object
          }
        ]
    }

-- The storage option is required and defines which storage backend is in use. You must configure exactly one backend.
-- Note: age and interval are strings containing a number with optional fraction and a unit suffix. Some examples: 45m, 2h10m, 168h.
let Filesystem =
  { rootdirectory: Text -- /var/lib/registry
  ,  maxthreads: Natural -- 100
  }

let Azure =
  { accountname: Text -- accountname
  , accountkey: Text -- base64encodedaccountkey
  , container: Text -- containername
  }

let GoogleCloudStorage =
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

let S3 =
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

let OpenstackSwift =
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

let AliyunOss =
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

let Storage =
  { filesystem: Filesystem
  , azure: Azure
  , gcs: GoogleCloudStorage
  , s3: S3
  , swift: OpenstackSwift
  , oss: AliyunOss
  , inmemory:  {} --# This driver takes no parameters
  , delete:
    { enabled: Bool -- false
    }
  , redirect:
    { disable: Bool -- false
    }
  , cache:
    { blobdescriptor: Text -- redis or inmemory
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

-- You can configure only one authentication provider.
let Auth : Type =
  { silly:
    Optional
    { realm: Text -- silly-realm
    , service: Text -- silly-service
    }
  , token:
    Optional
    { autoredirect: Bool --  true
    , realm: Text -- token-realm
    , service: Text -- token-service
    , issuer: Text -- registry-token-issuer
    , rootcertbundle: Text -- /root/certs/bundle
    }
  , htpasswd:
    Optional
    { realm: Text -- basic-realm
    , path: Text -- /path/to/htpasswd
    }
  }

let M : Type =
  { name: Text -- ARegistryMiddleware
  , options: Object
  }

let StorageCloudfront : Type =
  { name: Text -- cloudfront
  , options:
    { baseurl: Text -- https://my.cloudfronted.domain.com/
    , privatekey: Text -- /path/to/pem
    , keypairid: Text -- cloudfrontkeypairid
    , duration: Optional Text -- 3000s -- An integer and unit for the duration of the Cloudfront session. Valid time units are ns, us (or µs), ms, s, m, or h.
    , ipfilteredby: Optional Text -- none, aws or awsregion
    , awsregion: Optional Text -- us-east-1, use-east-2
    , updatefrenquency: Optional Text -- 12h
    , iprangesurl: Optional Text -- https://ip-ranges.amazonaws.com/ip-ranges.json
    }
  }

let StorageRedirect =
  { name: Text  -- redirect
  , options:
    { baseurl: Text  -- https://example.com/
    }
  }

let Middleware : Type =
  { registry: M
  , repository: M
  , storage: StorageCloudfront
  -- , storage: StorageRedirect
  }

let Reporting : Type =
  { bugsnag:
    { apikey: Text  -- bugsnagapikey
    , releasestage: Optional Text  -- bugsnagreleasestage
    , endpoint: Optional Text  -- bugsnagendpoint
    }
  , newrelic:
    { licensekey: Text -- newreliclicensekey
    , name: Optional Text -- newrelicname
    , verbose: Optional Bool -- true
    }
  }

let Http : Type =
  { addr: Text -- localhost:5000
  , net: Text -- unix,  tcp
  , prefix: Optional Text -- /my/nested/registry/
  , host: Optional Text -- https://myregistryaddress.org:5000
  , secret: Optional Text -- asecretforlocaldevelopment
  , relativeurls: Bool -- false
  , draintimeout: Optional Text -- 60s
  , tls:
    Optional
    { certificate: Text -- /path/to/x509/public
    , key: Text -- /path/to/x509/private
    , clientcas: Optional [ Text ] -- /path/to/ca.pem ,/path/to/another/ca.pem
    , letsencrypt:
      Optional
      { cachefile: Text -- /path/to/cache-file
      , email: Text -- emailused@letsencrypt.com
      , hosts: Optional [Text] -- [myregistryaddress.org]
      }
    }
  , debug:
    Optional
    { addr: Text -- localhost:5001
    , prometheus:
      { enabled: Optional Bool -- true
      , path: Optional Text -- /metrics
      }
    }
  , headers:
    Optional
    [ { mapKey: Text, mapValue: [Text] } ]
  , http2:
    Optional
    { disabled: Bool -- false
    }
  }

let Notifications :  Type =
{ events:
  Optional
  { includereferences: Bool -- true
  }
, endpoints:
    [
      { name: Text -- alistener
      , disabled: Optional Bool -- false
      , url: Text -- https://my.listener.com/event
      , headers: Text -- <http.Header>
      , timeout: Text -- 1s --  value for the HTTP timeout. A positive integer and an optional suffix indicating the unit of time, which may be ns, us, ms, s, m, or h
      , threshold: Natural -- 10
      , backoff: Text -- 1s value for the HTTP timeout. A positive integer and an optional suffix indicating the unit of time, which may be ns, us, ms, s, m, or h
      , ignoredmediatypes: Optional [ Text ] -- [application/octet-stream ]
      , ignore:
        Optional
        { mediatypes: [ Text ] -- [application/octet-stream ]
        , actions: [ Text ] -- [ pull ]
        }
      }
    ]
}

let Redis : Type  =
  { addr: Text -- localhost:6379
  , password: Optional Text -- asecret
  , db: Optional Natural -- 0
  , dialtimeout: Optional Text -- 10ms
  , readtimeout: Optional Text -- 10ms
  , writetimeout: Optional Text -- 10ms
  , pool:
    { maxidle: Optional Natural -- 16
    , maxactive: Optional Natural -- 64
    , idletimeout: Optional Text -- 300s
    }
  }

let Health : Type =
  { storagedriver:
    { enabled: Bool -- true
    , interval: Optional Text -- 10s
    , threshold: Optional Natural -- 3
    }
  , file:
    [ { file: Text -- /path/to/checked/file
      , interval: Optional Text -- 10s
      }
    ]
  , http:
    [ { uri: Text -- http://server.to.check/must/return/200
      , headers:
        Optional
        { Authorization: Text -- [Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==]
        }
      , statuscode: Optional Natural --  200
      , timeout: Optional Text -- 3s
      , interval: Optional Text -- 10s
      , threshold: Optional Natural -- 3
      }
    ]
  , tcp:
    [ { addr: Text -- redis-server.domain.com:6379
      , timeout: Optional Text -- 3s
      , interval: Optional Text -- 10s
      , threshold: Optional Natural --  3
      }
    ]
  }

let Proxy : Type =
  { remoteurl: Text -- https://registry-1.docker.io
  , username: Optional Text -- [username]
  , password: Optional Text -- [password]
  }

let Compatibility : Type =
  { schema1:
    { signingkeyfile: Optional Text -- /etc/registry/key.json
    , enabled: Optional Bool -- true
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
  , auth: Optional Auth
  , middleware: Optional Middleware
  , reporting: Reporting
  , http: Http
  , notifications: Optional Notifications
  , redis: Redis
  , health: Optional Health
  , proxy: Proxy
  , compatibility: Compatibility
  , validation: Validation
  }

in
  Repository
