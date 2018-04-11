Configuration and scripts for deploying ModSecurity v3 with Nginx

## About
These configurations and scripts are for our use and have not been tested for anything other than our intended purpose.

### Building new binaries
```
  wget -qO - https://raw.githubusercontent.com/OnyxFireInc/modsecurity-nginx/master/build.sh | bash
```

### Deploying latest version
```
  wget -qO - https://raw.githubusercontent.com/OnyxFireInc/modsecurity-nginx/master/deploy.sh | bash
```

## License
The custom configurations and scripts in this project were created for our sole use but you may use them at your own risk. They are released under the [GPLv3 License](https://raw.githubusercontent.com/OnyxfireInc/modsecurity-nginx/master/LICENSE).

__libmodsecurity__ is Copyright (c) 2015 Trustwave Holdings, Inc. (http://www.trustwave.com/) and released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)

__modsecurity-nginx__ is Copyright (c) 2015 Trustwave Holdings, Inc. (http://www.trustwave.com/) and released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)
