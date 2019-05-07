# InfluxDB Run Script

This folder contains a script for configuring and initializing InfluxDB on a [GCP](https://cloud.google.com/gcp/) server instance. 
This script has been tested on the following operating systems:

* Ubuntu 18.04

There is a good chance it will work on other flavors of Debian, CentOS, and RHEL as well.

## Quick start

This script assumes you installed influxdb, plus all of its dependencies (including InfluxDB itself), using the 
[install-influxdb module](../install-influxdb). 

This will:

1. Fill out the templated configuration file with user supplied values.

1. Start InfluxDB on the local node.

1. Wait for the Meta and Data Instance Groups to spin up all desired instances then update `/etc/hosts` with the IPs of all instances. The value of the instances' `Name` label is used as the `hostname` entry.
   
1. Figure out a rally point for your InfluxDB cluster. This is a "leader" Meta node that will be responsible for initializing the cluster. See [Picking a rally point](#picking-a-rally-point) for more info.
   
1. On the rally point, initialize the cluster, including adding all Meta and Data nodes to the cluster

We recommend using the `run-influxdb` command as part of the instance [Startup Script](https://cloud.google.com/compute/docs/startupscript), so that it executes when the Compute Instance is first booting.

See the [examples folder](../../examples) for fully-working sample code.

## Command line Arguments

Run `run-influxdb --help` to see all available arguments.

```
Usage: run-influxdb [options]

This script can be used to configure and initialize InfluxDB. This script has been tested with Ubuntu 18.04.

Options:

  --hostname         The hostname of the current node.
  --node-type        Specifies whether the instance will be a Meta or Data node. Must be one of 'meta' or 'data'.
  --meta-group-name  The name of the Instance Group that contains meta nodes.
  --data-group-name  The name of the Instance Group that contains data nodes.
  --region           The GCP region the Instance Groups are deployed in.
  --auto-fill        Search the InfluxDB config file for KEY and replace it with VALUE. May be repeated.

Example:

  run-influxdb --node-type meta --meta-group-name ig-meta --data-group-name ig-data --region europe-north1 --auto-fill '<__LICENSE_KEY__>=******'
```

## Picking a rally point

The Influx cluster needs a "rally point", which is a single Meta node that is responsible for:

1. Initializing the cluster.
1. Adding/removing nodes to the cluster.

We need a way to unambiguously and reliably select exactly one rally point. If there's more than one node, you may end up with multiple separate clusters instead of just one!

The `run-influxdb` script can automatically picks a rally point automatically by:

1. Looking up all the servers in the Instance Group specified via the `--cluster-name` parameter.

1. Pick the meta node with the alphabetically first Instance ID.

## Passing credentials securely

The `run-influxdb` script requires that you pass in your license key and shared secret. You should make sure to never store these credentials in plaintext! You should use a secrets management tool to store the credentials in an encrypted format and only decrypt them, in memory, just before calling `run-influxdb`. Here are some tools to consider:

* [Vault](https://www.vaultproject.io/)
* [Keywhiz](https://square.github.io/keywhiz/)

Moreover, if you're ever calling `run-influxdb` interactively (i.e., you're manually running CLI commands
rather than executing a script), be careful of passing credentials directly on the command line, or they will be stored, in plaintext, [in Bash history](https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps)!

You can either use a CLI tool to set the credentials as environment variables or you can [temporarily disable Bash history](https://linuxconfig.org/how-to-disable-bash-shell-commands-history-on-linux). 

## Required permissions

The `run-influxdb` script assumes the [Compute Instance Service Account](<https://cloud.google.com/compute/docs/access/service-accounts#associating_a_service_account_to_an_instance>) has at least the following [permissions](https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions):

* `compute.instanceGroups.get`
* `compute.instanceGroups.list`
* TODO: Verify which permissions are really needed

These permissions are automatically added by the [influxdb-cluster module](../influxdb-cluster).

## Debugging tips and tricks

Some tips and tricks for debugging issues with your InfluxDB cluster:

* Log file locations: https://docs.influxdata.com/enterprise_influxdb/v1.6/administration/logs/.
* Use `systemctl status influxdb` to see if systemd thinks the InfluxDB process is running.