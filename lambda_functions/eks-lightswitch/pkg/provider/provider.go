package provider

import (
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
)

type Provider interface {
	GetKubeClient(config *rest.Config) (kubernetes.Interface, error)
	TokenGenerator() token.Generator
}
type provider struct {
}

func New() *provider {
	return &provider{}
}

func (p *provider) TokenGenerator() token.Generator {
	gen, _ := token.NewGenerator(true, false)
	return gen
}

func (p *provider) GetKubeClient(config *rest.Config) (kubernetes.Interface, error) {
	client, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, err
	}
	return client, nil
}
