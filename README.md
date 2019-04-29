# Batch Connect - OSC Galaxy

An interactive app designed for OSC OnDemand that launches Galaxy
within an Owens batch job.

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node):

- [Lmod] 6.0.1+ or any other `module restore` and `module load <modules>` based
  CLI used to load appropriate environments within the batch job before
  launching Galaxy.

[Lmod]: https://www.tacc.utexas.edu/research-development/tacc-projects/lmod

## Install

The Install process runs on the **login node**

Use git to clone this app and checkout the desired branch/version you want to
use:

```sh
git clone <repo>
cd <dir>
git checkout <tag/branch>
```

Use git to initialize and clone submodule Galaxy:

```sh
git submodule init
git submodule update
```

Create database and install dependencies required by Galaxy:

```sh
cd galaxy
sh install_dependencies.sh 
sh create_db.sh
```

You will not need to do anything beyond this as all necessary assets are
installed. You will also not need to restart this app as it isn't a Passenger
app.

To update the app you would:

```sh
cd <dir>
git fetch
git checkout <tag/branch>
```

Again, you do not need to restart the app as it isn't a Passenger app.

## Contributing

1. Fork it ( https://github.com/OSC/bc_osc_galaxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
