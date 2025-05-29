#################
# glauth.conf

#################
# General configuration.
debug = false
# syslog = true
# structuredlog = true
#
# Enable hot-reload of configuration on changes
# - does NOT work [ldap], [ldaps], [backend] or [api] sections
# watchconfig = true

#################
# Server configuration.
[ldap]
  enabled = true
  listen = "0.0.0.0:${ldap_port}"
  tls = false # enable StartTLS support
  tlsCertPath = "/etc/glauth/tls/crt.pem"
  tlsKeyPath = "/etc/glauth/tls/key.pem"

[ldaps]
  enabled = true
  listen = "0.0.0.0:${ldaps_port}"
  cert = "/etc/glauth/tls/crt.pem"
  key = "/etc/glauth/tls/key.pem"

#################
# Tracing section controls the tracer configuration
[tracing]
  # if enabled is set to false, a no-op tracer will be used
  enabled = ${tracing_config.enabled}
  # if both grpcEndpoint and httpEndpoint are unset, the default stdout provider will be used
  # TODO add allowGRPCInsecure: right now grpc otlp is using the WithInsecure flag so traffic
  # will always go without verifying server certificates
  # grpcEndpoint = "otlp.monitoring.io:4317"
  # httpEndpoint = "http://otlp.monitoring.io:4318"
#################
# The backend section controls the data store.
[backend]
  datastore = "config"
  baseDN = "${backend_config.base_dn}"

  # If you are using a client that requires reading the root DSE first
  # such as SSSD
  anonymousdse = false

  ## Configure dn format to use structures like
  ## "uid=serviceuser,cn=svcaccts,$BASEDN" instead of "cn=serviceuser,ou=svcaccts,$BASEDN"
  ## to help ease migrations from other LDAP systems
  %{~ if backend_config.legacy }
  nameformat = "uid"
  groupformat = "cn"
  %{~ endif }

  ## Configure ssh-key attribute name, default is 'sshPublicKey'
  # sshkeyattr = "ipaSshPubKey"

[behaviors]
  # Ignore all capabilities restrictions, for instance allowing every user to perform a search
  IgnoreCapabilities = false
  # Enable a "fail2ban" type backoff mechanism temporarily banning repeated failed login attempts
  LimitFailedBinds = true
  # How many failed login attempts are allowed before a ban is imposed
  NumberOfFailedBinds = 3
  # How long (in seconds) is the window for failed login attempts
  PeriodOfFailedBinds = 10
  # How long (in seconds) is the ban duration
  BlockFailedBindsFor = 60
  # Clean learnt IP addresses every N seconds
  PruneSourceTableEvery = 600
  # Clean learnt IP addresses not seen in N seconds
  PruneSourcesOlderThan = 600

#### USERS ####

%{~ for user in users }
[[users]]
  name = "${user.name}"
  uidnumber = ${user.uid}
  primarygroup = ${user.primary_gid}
  loginShell = "${user.login_shell}"
  passsha256 = "${user.pass_sha_256}"
    %{~ for capability in user.capabilities }
    [[users.capabilities]]
    action = "${capability.action}"
    object = "${capability.object}"
    %{~ endfor }
%{~ endfor }


#### GROUPS #####

%{~ for group in groups }
[[groups]]
  name = "${group.name}"
  gidnumber = ${group.gid}
  %{~ for capability in group.capabilities }
    [[groups.capabilities]]
    object = "${capability.object}"
    action = "${capability.action}"
  %{~ endfor }
%{~ endfor }
