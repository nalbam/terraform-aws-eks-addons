resources:
  - apiVersion: install.istio.io/v1alpha1
    kind: IstioOperator
    metadata:
      name: istio
      namespace: istio-system
    spec:
      components:
        ingressGateways:
          - name: istio-ingressgateway
            enabled: true
      addonComponents:
        kiali:
          enabled: true
        tracing:
          enabled: true
        grafana:
          enabled: true
        prometheus:
          enabled: true
      values:
        global:
          mtls:
            auto: true
            enabled: false
          proxy:
            accessLogFile: /dev/stdout
            logLevel: "info"
          istiod:
            enabled: true
        gateways:
          istio-ingressgateway:
            type: NodePort
            autoscaleEnabled: true
            autoscaleMin: ${AS_MIN}
            autoscaleMax: ${AS_MAX}
            serviceAnnotations:
              service.beta.kubernetes.io/aws-load-balancer-type: nlb
            ports:
              - name: status-port
                port: 15020
                targetPort: 15020
              - name: http2
                nodePort: 31380
                port: 80
                targetPort: 80
              - name: https
                nodePort: 31390
                port: 443
                targetPort: 443
              - name: tls
                port: 15443
                targetPort: 15443
            nodeSelector:
              group: ingress
            tolerations:
              - key: group
                operator: Equal
                effect: NoSchedule
                value: ingress
            sds:
              enabled: true
        kiali:
          enabled: true
          createDemoSecret: true
          # ingress:
          #   enabled: false
          #   hosts:
          #   annotations:
          nodeSelector:
            group: operation
          tolerations:
            - key: group
              operator: Equal
              effect: NoSchedule
              value: operation
          # prometheusAddr: http://prometheus-operator-prometheus.addon-prometheus.svc.cluster.local:9090
          # doesn't works: https://github.com/istio/istio/issues/19719
        tracing:
          enabled: true
          # ingress:
          #   enabled: false
          #   hosts:
          #   annotations:
          nodeSelector:
            group: operation
          tolerations:
            - key: group
              operator: Equal
              effect: NoSchedule
              value: operation
        grafana:
          enabled: true
        prometheus:
          enabled: true
