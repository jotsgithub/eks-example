package config

import (
	"eks-lightswitch/pkg/provider"
	"encoding/base64"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
)

type Factory interface {
	GetKubeClient(clusterName, clusterEndpoint, caCert string) (kubernetes.Interface, error)
}

func New(p provider.Provider) *factory {
	return &factory{p}
}

type factory struct {
	provider provider.Provider
}

func (f *factory) GetKubeClient(clusterName, clusterEndpoint, caCert string) (kubernetes.Interface, error) {
	options := &token.GetTokenOptions{ClusterID: clusterName}
	token, err := f.provider.TokenGenerator().GetWithOptions(options)
	if err != nil {
		return nil, err
	}
	b64CaCrt, err := base64.StdEncoding.DecodeString(caCert)
	if err != nil {
		return nil, err
	}
	tlsClientConfig := rest.TLSClientConfig{}
	tlsClientConfig.CAData = b64CaCrt

	restConfig := &rest.Config{
		Host:            clusterEndpoint,
		TLSClientConfig: tlsClientConfig,
		BearerToken:     token.Token,
	}
	client, err := f.provider.GetKubeClient(restConfig)
	return client, err
}
