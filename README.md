Configuration and scripts for deploying ModSecurity v3 with Nginx

## About
These configurations and scripts are for our use and have not been tested for anything other than our intended purpose.

```
    Configuration and scripts for deploying ModSecurity v3 with Nginx
    Copyright (C) 2017  OnyxFire, Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
```

### Building new binaries
```
  curl -s https://raw.githubusercontent.com/OnyxFireInc/modsecurity-nginx/master/build.sh | bash
```

### Deploying latest version
```
  curl -s https://raw.githubusercontent.com/OnyxFireInc/modsecurity-nginx/master/deploy.sh | bash
```

### Deploying for specific version
```
  curl -s https://raw.githubusercontent.com/OnyxFireInc/modsecurity-nginx/master/deploy.sh | bash -s v1.15.8
```

## License
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

__libmodsecurity__ is Copyright (c) 2015 Trustwave Holdings, Inc. (http://www.trustwave.com/) and released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)

__modsecurity-nginx__ is Copyright (c) 2015 Trustwave Holdings, Inc. (http://www.trustwave.com/) and released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0)
