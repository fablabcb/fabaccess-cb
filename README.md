# fabaccess-cb


### Decrypt secrets

When you add a new secret to the `secrets.yaml` 
you have to decrypt the file first:
```bash
make secrets-decrypt -e ENVIRONMENT=prod
```

### Encrypt secrets

Before you commit any changes to the git repo
you have to encrypt the `secrets.yaml` first:
```bash
make secrets-encrypt -e ENVIRONMENT=prod
```

### Setup host

```bash
make setup -e TAGS=common
```