# Repositorio APT de forma mais simples

1. Tenha os pacotes .deb dentro da pasta `package`
2. Tenha gerado um par de chaves OpenGPG v2 ou v1, e colocar estes par de chaves dentro da pasta `keys`

3. Crie um arquivo yml no diretorio `.github/workflows` com qualquer nome e coloque a seguinte conteudo:
```yml
name: Apt
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    name: Build
    steps:
    - name: Checkout
      uses: actions/checkout@main
    - name: Apt PUblish
      uses: Sirherobrine23/apt-pages-repo-actions@main
      with:
        KEY_ID: '908144B521689A950CCB5E801347937B188623BC'
        URL_REPO: 'https://sirherobrine23.github.io/apt-pages-repo-actions'
        PASS: "${{ secrets.PASSWORD }}"
    - name: Deploy
      uses: peaceiris/actions-gh-pages@v3.7.0-8
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: aptly/public/
```

4. publique o repositorio
