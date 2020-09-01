---
name: Bug report
about: Let us know about a bug!
---

## What happened?

## What did you expect to happen?

## Steps to reproduce

1. Ran `x`
2. Clicked `y`
3. Saw error `z`

## What's your environment like?

- Chart version:
- Container image: 
- Kubernetes version:
- Cloud provider:
- Other details:

## What are your chart values?

```values.yaml
# Paste here
# Be sure to scrub any sensitive values
```

## What are the contents of your config secret?

`kubectl get secret pomerium -o=jsonpath="{.data['config\.yaml']}" | base64 -D`

```values.yaml
# Paste here
# Be sure to scrub any sensitive values
```


## What did you see in the logs?

```logs
# Paste your logs here.
# Be sure to scrub any sensitive values
```

## Additional context

Add any other context about the problem here.
