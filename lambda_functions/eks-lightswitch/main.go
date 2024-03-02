package main

import (
	"context"
	"eks-lightswitch/pkg/config"
	"eks-lightswitch/pkg/provider"
	"fmt"
	"strings"

	"github.com/aws/aws-lambda-go/lambda"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func main() {

	lambda.Start(handleLambda(config.New(provider.New())))
}

type MyEvent struct {
	ClusterName     string `json:"clusterName"`
	ClusterEndpoint string `json:"clusterEndpoint"`
	ClusterCA       string `json:"clusterCA"`
}

type MyResponse struct {
	Message string `json:"message"`
	Time    string `json:"time"`
}

func handleLambda(f config.Factory) func(ctx context.Context, event MyEvent) (MyResponse, error) {
	return func(ctx context.Context, event MyEvent) (MyResponse, error) {
		fmt.Println("Lightswitch Lambda start")
		fmt.Printf("Lightswitch Lambda inputs, clusterName(%s), clusterEndpoint(%s)\n", event.ClusterName, event.ClusterEndpoint)
		kclient, err := f.GetKubeClient(event.ClusterName, event.ClusterEndpoint, event.ClusterCA)
		response := MyResponse{}
		if err != nil {
			return response, err
		}
		fmt.Println("successfully got a kube client")
		ds, err := kclient.AppsV1().Deployments("gpu-operator").List(context.TODO(), v1.ListOptions{})
		if err != nil {
			return response, err
		}
		dsSize := len(ds.Items)
		fmt.Printf("dsSize:%d\n", dsSize)
		fmt.Printf("ds item[0]:%s\n", &ds.Items[0])
		names := []string{}
		for _, d := range ds.Items {
			names = append(names, d.Name)
		}

		response = MyResponse{
			Message: fmt.Sprintf("Deployments->(%s)", strings.Join(names, ",")),
		}
		return response, nil
	}
}
