# consul-template-plugin-all_services

[consul-template](https://github.com/hashicorp/consul-template) plugin to query all [Consul](https://www.consul.io) services in every DC

How to query all available services in all Consul datacenters (multi-datacenter environment)? Standart "services" function will query all services only in current (or named datacenter).

With this plugin you can do this easily.

## Installation

You need perl and these perl modules: common::sense, LWP::UserAgent, Cpanel::JSON::XS, List::MoreUtils, List::Util. You can install them by apt or cpanm (sometimes some of them are already installed)

```
apt install libcommon-sense-perl libwww-perl libcpanel-json-xs-perl liblist-moreutils-perl
```

```
cpanm -S common::sense LWP::UserAgent Cpanel::JSON::XS List::MoreUtils List::Util
```

Install into system PATH

```
sudo cp all_services.pl /usr/local/bin
```

## Usage

Test run from comand line

```
CONSUL_HTTP_ADDR=consul.service.consul:8500 all_services.pl
```

Usage from consul-template (CONSUL_HTTP_ADDR environment variable must be set)

```
{{range $service_name := plugin "all_services.pl" | split "\n" }}
  {{$service_name}}
{{end}}
```

Filter by tag (will get all services with any of these tags)

```
{{range $service_name := plugin "all_services.pl" "some-tag-1" "some-tag-2" ... "some-tag-n" | split "\n" }}
  {{$service_name}}
{{end}}
```
