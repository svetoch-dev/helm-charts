# Helm charts

## Structure
* there are highlevel charts and charts that are used as a dependency to highlevel charts
* highlevel charts represent a service or stack (for example konghq, prometheus)
* Chart that are used as dependencies (dependency charts) to highlevel charts are placed in `charts/chart_deps` folder 
* highlevel chart is a subset of external or dependency (the ones in `charts/chart_deps`) charts

## TBD
* Add docs for each module

## More info

Checkout https://github.com/ggramal/infrared for more info

## Prerequisites
Before doing anything in this repo please follow this steps
1. Install pre-commit `pip install pre-commit`
2. Clone this project
3. Run `pre-commit install` from the project dir
