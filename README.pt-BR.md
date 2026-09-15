# Currency Converter API 💱

> 🌍 **Idioma:** [English](README.md) | **Português**

> **Projeto de Portfólio - Desenvolvedor Ruby on Rails Sênior**
>
> API Rails 7.1 pronta para produção para conversão de moedas em tempo real com autenticação JWT, cobertura abrangente de testes (TDD) e deployment em nuvem com arquitetura Scale-to-Zero automatizada.

🌐 **Aplicação Live:** https://currency-converter-ruby.fly.dev | 📚 **Docs Interativas (Swagger):** https://currency-converter-ruby.fly.dev/api-docs | ✅ **190 testes passando** (79% de cobertura)

---

## 🌟 Destaques Técnicos & Padrões de Engenharia

| Dimensão | Arquitetura & Implementação | Evidência / Código |
| :--- | :--- | :--- |
| **Arquitetura Rails 7.1 Limpa** | Modo API-only enxuto, Bootsnap, Puma e Service Objects para isolamento estrito das regras de negócio | [Gemfile](backend/Gemfile) • [Services](backend/app/services/) |
| **Banco de Dados Relacional** | PostgreSQL gerenciado (Supabase) via Transaction Pooler (Supavisor), SSL e migrações no deploy | [database.yml](backend/config/database.yml) • [Schema](backend/db/schema.rb) |
| **Estratégia de Cache Resiliente** | Cache de taxas de câmbio (TTL de 24h) com fallback gracioso de Redis para memory store em caso de ausência | [ExchangeRateProvider](backend/app/services/exchange_rate_provider.rb) • [redis.rb](backend/config/initializers/redis.rb) |
| **Test-Driven Development (TDD)** | 190+ specs (Request, Service, Model, Serializer) com 79% de cobertura de código via RSpec & FactoryBot | `bundle exec rspec` • [spec/](backend/spec/) |
| **Cloud Native & DevOps** | Container Docker multi-stage implantado no **Fly.io** com orquestração **Scale-to-Zero** (custo zero ocioso) | [Dockerfile](backend/Dockerfile) • [fly.toml](backend/fly.toml) |
| **Segurança em Camadas** | Autenticação stateless JWT (Devise), Rate Limiting (Rack::Attack), Brakeman e Bundler Audit automatizados | [rack_attack.rb](backend/config/initializers/rack_attack.rb) • [Devise](backend/config/initializers/devise.rb) |
| **Observabilidade & Confiabilidade** | Logs JSON estruturados com Lograge, sondas duplas de health check (`/up` e `/api/v1/health`), RuboCop rigoroso | [HealthController](backend/app/controllers/api/v1/health_controller.rb) • [.rubocop.yml](backend/.rubocop.yml) |
| **Documentação Interativa** | Especificação OpenAPI 3.0 com Swagger UI ao vivo para testes diretos pelo navegador | [Swagger UI](https://currency-converter-ruby.fly.dev/api-docs) • [swagger.yaml](backend/swagger/v1/swagger.yaml) |

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

## 🏛️ Filosofia de Engenharia & Boas Práticas

Este microsserviço reflete princípios de Engenharia de Software Consciente aplicados em nível sênior:

1. **Decisões Orientadas a Dados:** Cobertura de testes de 79%, logs estruturados de performance e monitoramento de saúde garantem confiabilidade mensurável.
2. **Relações Claras entre Módulos:** Fronteiras bem delimitadas entre controllers, services, serializers e gateways externos garantem facilidade de manutenção.
3. **Compreensão de Impacto e Intenção:** Documentação arquitetural profunda e histórico de commits limpo explicam o *porquê* das escolhas, não apenas o *o quê*.
4. **Qualidade Contínua:** Pipelines de CI/CD validam linters, scanners de vulnerabilidades e testes automatizados antes de qualquer deploy.

**Funcionalidades de Nível de Produção:**
- Deploy cloud-native com Scale-to-Zero automatizado (otimização de recursos e custo zero ocioso)
- Scans de segurança automatizados integrados ao CI/CD
- Tráfego criptografado com terminação SSL/TLS via Fly Proxy
- Logging estruturado em JSON (Lograge) ideal para agregadores de telemetria modernos

---

**Desenvolvido com ❤️ usando Ruby on Rails** | [Ver Aplicação Live →](https://currency-converter-ruby.fly.dev/api-docs)
