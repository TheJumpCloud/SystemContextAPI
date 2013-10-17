JumpCloud System Context API
================

## Introduction

The JumpCloud System Context API is a REST API for manipulating the system the JumpCloud Agent is installed on. 
To use the System Context API you must first [create a JumpCloud account](https://console.jumpcloud.com/register/) and [add a system to be managed](https://jumpcloud.com/systems).
From the system that has the JumpCloud Agent you can now use the REST API in the context of that system. 

### Authentication

To allow for secure access to the API you must authentication each API request. 
The JumpCloud API uses [HTTP Signatures](http://tools.ietf.org/html/draft-cavage-http-signatures-00) to authenticate API requests. 
Http Signatues is similar to the Amazon Web Services REST API where you send a signature with each request.
To help with the request signing process there is an exmaple bash sciript. Let's have a look at it...




