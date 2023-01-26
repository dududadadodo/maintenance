### Installation
#### Download and execute the script:

```bash
$ git clone https://github.com/dududadadodo/maintenance.git
$ cd maintenance
$ chmod +x init.sh
$ ./init.sh
$ chmod +x maintenance.sh
```

#### Add to server directive

```
server {

## Nginx Maintenance Mode
include snippets/maintenance-page.conf;

}
```

#### Usage

```bash
$ ./maintenance.sh [hostname] [on/off]
```