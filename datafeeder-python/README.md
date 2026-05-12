# About

This repository holds a helm chart for mviewer and mviewerstudio. This README file aims to present
some of the features and/or implementation choices.

# Maintainers

## How to create a new chart release
1. Change the version in the Chart.yaml.  
   Please follow https://semver.org, if you are adding a new feature bump the MINOR version, otherwise if it's a bugfix bump the PATCH version.
2. Write a changelog in the CHANGELOG.md
3. Push your changes.

# Usage

## Install

WARNING: Change `X.X.X` by the latest version of the helm chart found in https://github.com/mviewer/helm-charts/blob/main/mviewer/Chart.yaml#L18

### Quick start

1. Check the Chart version and use that version in 2nd step: https://github.com/mviewer/helm-charts/blob/main/mviewer/Chart.yaml#L18
2. Execute this command for installing the mviewer chart:  
   ```
   helm install mviewer oci://ghcr.io/mviewer/helm-charts/mviewer --version X.X.X
   ```
   
4. Go to [https://YOURDOMAIN](https://YOURDOMAIN) OR [https://YOURDOMAIN/mviewerstudio](https://YOURDOMAIN/mviewerstudio)

### Customized installation
1. Create a new separate 'values' file (or edit the existing one, not recommended).

2. Check the Chart version and use that version in 3rd step: https://github.com/mviewer/helm-charts/blob/main/mviewer/Chart.yaml#L18

3. Execute this command for installing the mviewer chart:  
   ```
   helm install -f your-values.yaml mviewer oci://ghcr.io/mviewer/helm-charts/mviewer --version X.X.X
   ```

4. Go to [https://YOURDOMAIN](https://YOURDOMAIN) OR [https://YOURDOMAIN/mviewerstudio](https://YOURDOMAIN/mviewerstudio)

## Upgrade

Apply only for a customized installation.

```
helm upgrade -f your-values.yaml mviewer oci://ghcr.io/mviewer/helm-charts/mviewer --version 0.7.0
```
