# Quality Emitter VM

A Vagrant-provisioned virtual machine to create a suitable development environment for the [Quality Emitter](http://quality-emitter.geoviqua.org) that was developed as part of the [GeoViQua](http://geoviqua.org) project. This enables you to run a local copy of the Ruby on Rails front-end application ([computeqi-web](https://github.com/GeoViQua/computeqi-web)) as well as locally deploy the back-end API ([emulatorization-api](https://github.com/GeoViQua/emulatorization-api)) for further testing/development.

This environment is **not** suitable for production.

## Prerequisites

* You have installed [VirtualBox](https://www.virtualbox.org/) (followed by the Extension Pack) and [Vagrant](http://vagrantup.com/)
* You have your own fork of [computeqi-web](https://github.com/GeoViQua/computeqi-web)
* (Optional) you have your own fork of [emulatorization-api](https://github.com/GeoViQua/emulatorization-api)

## Getting Started

First, clone this repository and change directory:

```bash
$ git clone https://github.com/lushc/vagrant-computeqi
$ cd vagrant-computeqi
```

You'll need to clone your fork of computeqi-web into the `src` directory. If you'll be building and testing modifications to emulatorization-api then clone it into the src directory also:

```bash
$ git clone https://github.com/<username>/computeqi-web src/computeqi-web
$ git clone https://github.com/<username>/emulatorization-api src/emulatorization-api
```

Rename the example computeqi-web configuration files by removing the `.example` extension:

```bash
$ cd src/computeqi-web/config
$ mv api.yml.example api.yml
$ mv mongoid.yml.example mongoid.yml
```

Everything can be left as default unless you're **not** going to deploy a local copy of emulatorization-api, in which case you need to edit `api.yml` to point to an external instance of emulatorization-api.

Next, go back up to the `vagrant` directory, install the Librarian-Chef plugin and boot up the VM:

```bash
$ cd ../../../vagrant
$ vagrant plugin install vagrant-librarian-chef
$ vagrant up
```

Vagrant will then begin the process of booting & provisioning the VM. Once finished you can SSH in and control the VM directly:

```bash
$ vagrant ssh
```

## Usage

### Accessing Applications

Vagrant will have forwarded the following ports to allow access to the application from the host machine (i.e. outside of the VM):

* [http://localhost:3000](http://localhost:3000) - The Rails server that's hosting the computeqi-web application.
* [http://localhost:8080](http://localhost:8080) - Tomcat. The manager and host-manager webapps can be accessed with the username `vagrant` and password `vagrant`
* [http://localhost:27017](http://localhost:27017) - MongoDB. Use something like [Robomongo](http://robomongo.org/) if you want to inspect the computeqi-web database using a GUI.

NB. If a forwarded port doesn't work then it's likely that port was already in use on your host machine and was auto-corrected. The correct port will appear in the console output, e.g.

```
[default] Fixed port collision for 8080 => 8080. Now on port 2203.
```

If you've since fixed the conflict and want to use the intended port, or missed what it was corrected to, reload the configuration with `vagrant reload`

### Deploying emulatorization-api

Simply build the project using your favourite IDE that supports Maven and copy the resulting WAR file (`emulatorization-api.war`) from `src/emulatorization-api/target` to `src/webapps` - Tomcat will automatically hot deploy it. Alternatively you could upload the WAR through the manager webapp (see above).

If it doesn't work, you may be missing a configuration file found under `src/emulatorization-api/src/main/resources` called `et.production.yml` - an example configuration would be:

```yaml
# A server that runs an instance of matlab-connector on the specified port
# https://github.com/itszootime/matlab-connector
matlab:
  host: example.com
  port: 12345
  gpml_path: /path/to/gpmlab-2.0
# A server that runs Rserve on the specified port
rserve:
  host: example.com
  port: 12346
# Base URL, should be left as default
webapp:
  url: http://localhost:8080/emulatorization-api
```

If you do deploy an instance of emulatorization-api this way, don't forget to edit `src/computeqi-web/config/api.yml` so that the development/test environments use localhost.

### Administration Tips

* The VM is Ubuntu 12.04 (Precise Pangolin) 32-bit, user is `vagrant` and `sudo` is passwordless
* Everything in the `src` folder can be accessed from within the VM under the directory `/home/vagrant/src`
* The Rails server starts detached so if you need to restart it you'll first need to change directory to `/home/vagrant/src/computeqi-web`, kill the process with `kill $(cat tmp/pids/server.pid)` and then start the server again with `rails s -d`
* If you make any changes to models that are Remotable or find that your jobs are stuck in a queue and are not being processed, you may have to restart the delayed_job worker with `sudo RAILS_ENV=development /home/vagrant/src/computeqi-web/script/delayed_job restart`

### Vagrant Tips

* Made a change to the Vagrantfile? Use `vagrant reload`
* Added a cookbook or changed `vagrant/provision.sh`? Use `vagrant provision`
* Want to safely close the VM but save its state? Use `vagrant suspend` (to resume it again, use `vagrant up`)
* Want to destroy the VM entirely? Use `vagrant destroy`

If you get the error "A Vagrant environment is required" make sure you're in the `vagrant` directory.