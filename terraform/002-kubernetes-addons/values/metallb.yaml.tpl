# ref: https://github.com/metallb/metallb/blob/main/charts/metallb/values.yaml

controller:
  enabled: true
  logLevel: ${log_level}
  resources:
    ${indent(4, yamlencode(controller.resources))}

speaker:
  logLevel: ${log_level}

  reloader:
    resources:
      ${indent(6, yamlencode(speaker.reloader.resources))}

  frrMetrics:
    resources:
      ${indent(6, yamlencode(speaker.frr_metrics.resources))}

  frr:
    resources:
      ${indent(6, yamlencode(speaker.frr.resources))}

  resources:
    ${indent(4, yamlencode(speaker.resources))}
