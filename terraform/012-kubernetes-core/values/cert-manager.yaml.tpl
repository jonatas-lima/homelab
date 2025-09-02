# ref: https://cert-manager.io/docs/installation/best-practice/

crds:
  enabled: true

config:
  apiVersion: controller.config.cert-manager.io/v1alpha1
  kind: ControllerConfiguration
  enableGatewayAPI: true

global:
  priorityClassName: "system-cluster-critical"

replicaCount: ${controller.replica_count}

podDisruptionBudget:
  enabled: true
  minAvailable: 1

serviceAccount:
  automountServiceAccountToken: false
automountServiceAccountToken: false

resources:
  ${indent(2, yamlencode(controller.resources))}

volumes:
  - name: serviceaccount-token
    projected:
      defaultMode: 0444
      sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            name: kube-root-ca.crt
            items:
              - key: ca.crt
                path: ca.crt
        - downwardAPI:
            items:
              - path: namespace
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
volumeMounts:
  - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
    name: serviceaccount-token
    readOnly: true

webhook:
  replicaCount: ${webhook.replica_count}
  podDisruptionBudget:
    enabled: true
    minAvailable: 1
  serviceAccount:
    create: true
    automountServiceAccountToken: false
  automountServiceAccountToken: false
  volumes:
    - name: serviceaccount-token
      projected:
        defaultMode: 0444
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - path: namespace
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
  volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: serviceaccount-token
      readOnly: true
  resources:
    ${indent(4, yamlencode(webhook.resources))}

cainjector:
  enabled: true
  replicaCount: ${cainjector.replica_count}
  podDisruptionBudget:
    enabled: true
    minAvailable: 1
  serviceAccount:
    create: true
    automountServiceAccountToken: false
  automountServiceAccountToken: false
  volumes:
    - name: serviceaccount-token
      projected:
        defaultMode: 0444
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - path: namespace
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
  volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: serviceaccount-token
      readOnly: true
  resources:
    ${indent(4, yamlencode(cainjector.resources))}

startupapicheck:
  enabled: true
  serviceAccount:
    create: true
    automountServiceAccountToken: false
  automountServiceAccountToken: false
  volumes:
    - name: serviceaccount-token
      projected:
        defaultMode: 0444
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - path: namespace
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
  volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: serviceaccount-token
      readOnly: true

prometheus:
  servicemonitor:
    enabled: true
