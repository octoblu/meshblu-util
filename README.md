# Meshblu Util
Generate and publish a public key based on meshblu.json credentials

[![Build Status](https://travis-ci.org/octoblu/meshblu-util.svg?branch=master)](https://travis-ci.org/octoblu/meshblu-util)


# Install
```
npm install -g meshblu-util
```

# Usage

## Register

Register a new device with meshblu

```
meshblu-util register > meshblu.json
```

## Subscribe

Subscribe to the device in meshblu.json

```
meshblu-util subscribe ./meshblu.json
```

Subscribe to a device that meshblu.json has permission to listen to

```
meshblu-util subscribe -u 422e55fe-d461-4db8-9554-96b16d5660b5 ./meshblu.json
```

# Get

Get your meshblu device
```
meshblu-util get ./meshblu.json
```

# Update

Update your meshblu device

```
meshblu-util update -d '{"online": true}' ./meshblu.json
```

# Keygen

Generate a secure keypair and update your device's publicKey

```
meshblu-util keygen ./meshblu.json
```
