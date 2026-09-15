# Currency Converter API 💱

> 🌍 **Idioma:** [English](README.md) | **Português**

> **Desenvolvedor Ruby on Rails Sênior - Avaliação Técnica para Jaya Tech**

API Rails pronta para produção para conversão de moedas em tempo real com autenticação JWT, cobertura completa de testes e deployment automatizado via CI/CD.

🌐 **Live:** https://currency-converter-ruby.fly.dev | 📚 **Docs API:** https://currency-converter-ruby.fly.dev/api-docs | ✅ **190 testes passando** (79% de cobertura)

---

## ✅ Requisitos da Avaliação Atendidos

| Requisito | Implementação | Evidência |
|-----------|---------------|-----------|
| **Rails 7.1+** | ✅ Rails 7.1.5 | [Gemfile](backend/Gemfile) |
| **PostgreSQL** | ✅ BD em Produção | [database.yml](backend/config/database.yml) |
| **Redis** | ✅ Cache & Sidekiq pronto | [redis.rb](backend/config/initializers/redis.rb) |
| **Testes RSpec** | ✅ 190 testes, 79% cobertura | `bundle exec rspec` |
| **CI/CD** | ✅ GitHub Actions | [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml) |
| **Git & Ágil** | ✅ PRs, commits convencionais | [Histórico de commits](https://github.com/fassousa/currency-converter-ruby/commits/main) |

**Bônus:** Docker ✅ | Scans de Segurança (Brakeman) ✅ | Documentação API (Swagger) ✅ | Deploy em Produção ✅ | HTTPS/SSL ✅

---

## 🚀 Início Rápido (30 segundos)

```bash
cd backend
bundle install
cp .env.example .env  # Adicione sua CURRENCY_API_KEY do currencyapi.com
rails db:setup
rails server
```

**Login de teste:** `admin@example.com` / `password`  
**Experimente:** Visite http://localhost:3000/api-docs para documentação interativa da API

---

## 🏗️ Arquitetura & Decisões Técnicas

**Padrões de Design:**
- Service Objects para isolamento de lógica de negócio
- Padrão Repository para chamadas de API externas
- Tratamento de erros customizado com códigos HTTP apropriados

**Performance:**
- Cache Redis (TTL de 24h para taxas de câmbio)
- Índices de banco de dados em chaves estrangeiras e colunas de busca
- Prevenção de queries N+1 com eager loading

**Segurança:**
- Autenticação JWT (Devise)
- Rate limiting: 100 req/min (Rack::Attack)
- Scans de segurança: Brakeman + Bundler Audit
- HTTPS com certificado SSL Let's Encrypt

**Garantia de Qualidade:**
- 190 testes RSpec com FactoryBot
- Linting RuboCop com melhores práticas Rails
- 79% de cobertura de código (SimpleCov)
- Pipeline CI/CD com testes automatizados

📖 **Aprofunde-se:** [Decisões de Arquitetura](ARCHITECTURE_DECISIONS.md) | [Guia de Desenvolvimento](DEVELOPMENT.md) | [Guia de Deployment](DEPLOYMENT.pt-BR.md)

---

## 📋 Funcionalidades Principais

- ✅ **10+ moedas** com taxas de câmbio em tempo real ([CurrencyAPI](https://currencyapi.com))
- ✅ **Autenticação JWT** para acesso seguro à API
- ✅ **Histórico de transações** com paginação e isolamento por usuário
- ✅ **Logging abrangente** com Lograge (logs JSON estruturados)
- ✅ **Health checks** para monitoramento (banco de dados, cache, API externa)
- ✅ **Documentação Swagger** auto-gerada a partir dos testes RSpec

---

## 🧪 Testes & Qualidade

```bash
bundle exec rspec              # Executar todos os testes (190 passando)
bundle exec rubocop            # Lint de estilo de código
bundle exec brakeman           # Scan de vulnerabilidades de segurança
open coverage/index.html       # Ver relatório de cobertura de testes
```

**Detalhamento da Cobertura de Testes:**
- Controllers: Request specs com autenticação
- Services: Testes unitários de lógica de negócio
- Models: Testes de validação e associação
- Serializers: Testes de formato de saída JSON
- Tratamento de erros: Specs de exceções customizadas

---

## 📚 Documentação

- 📖 [Exemplos de API](API_EXAMPLES.md) - Exemplos de requisição/resposta
- 📖 [Decisões de Arquitetura](ARCHITECTURE_DECISIONS.md) - Escolhas técnicas & justificativas
- 📖 [Guia de Desenvolvimento](DEVELOPMENT.md) - Setup local & workflows Docker
- 📖 [Guia de Deployment](DEPLOYMENT.pt-BR.md) ([EN](DEPLOYMENT.md)) - Setup de produção com HTTPS
- 📖 [Docs API Interativas](https://currency-converter-ruby.fly.dev/api-docs) - Swagger UI

---

## 🛠️ Stack Tecnológica

**Backend:** Rails 7.1 | PostgreSQL (Supabase) | Redis / Memory Store  
**Auth:** Devise + JWT (devise-jwt)  
**Testes:** RSpec | FactoryBot | SimpleCov | Shoulda Matchers  
**Qualidade:** RuboCop | Brakeman | Bundler Audit  
**DevOps:** Fly.io (Scale-to-Zero) | Docker | Puma | GitHub Actions  
**Monitoramento:** Lograge | Rack::Attack | Health Checks  

---

## 🌟 Por Que Esta Implementação?

**Para a "Engenharia de Software Consciente" da Jaya Tech:**

1. **Decisões Baseadas em Dados:** Cobertura abrangente de testes e monitoramento fornecem confiança
2. **Relacionamentos Saudáveis:** Arquitetura limpa facilita a colaboração em equipe
3. **Compreensão do Impacto:** Documentação explica o *porquê*, não apenas o *o quê*
4. **Autoconhecimento:** Cada commit segue convenções, testes validam premissas

**Funcionalidades Prontas para Produção:**
- Deploy com CI/CD, não apenas "funciona na minha máquina"
- Scans de segurança no pipeline, não surpresas pós-deployment
- Certificado SSL real, não placeholders auto-assinados
- Logging estruturado para debugging, não declarações `puts`

---

**Desenvolvido com ❤️ usando Ruby on Rails** | [Ver Aplicação Live →](https://currency-converter-ruby.fly.dev/api-docs)
