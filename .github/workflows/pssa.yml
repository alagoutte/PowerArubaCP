name: CI
on: [pull_request]
jobs:
  lint:
    name: Run PSSA
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: lint
      uses: devblackops/github-action-psscriptanalyzer@master
      with:
        repoToken: ${{ secrets.GITHUB_TOKEN }}