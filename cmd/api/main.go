package main

import "github.com/gin-gonic/gin"

const (
	port        = 8080
	host        = "0.0.0.0"
	serviceName = "twilio-server"
)

func main()  {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Welcome! We're under development.",
		})
	})
	panic(r.Run())
}

