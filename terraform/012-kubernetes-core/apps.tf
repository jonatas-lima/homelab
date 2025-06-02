# resource "helm_release" "this" {
#   for_each = local.helm_charts

#   name       = each.key
#   chart      = each.value.chart
#   repository = each.value.repository
#   values     = try([templatefile("./values/${each.key}.yaml.tftpl", each.value.vars)], [])
# }
