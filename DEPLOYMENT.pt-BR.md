# Guia de Implantação

> 🌍 **Language:** [English](DEPLOYMENT.md) | **Português**

A API Currency Converter está implantada no Digital Ocean com CI/CD automatizado via GitHub Actions.

## Ambiente de Produção

- **URL:** https://currencyconverter.duckdns.org
- **Docs API:** https://currencyconverter.duckdns.org/api-docs  
- **Plataforma:** Digital Ocean Droplet (Ubuntu 22.04)
- **Stack:** Nginx + Puma + PostgreSQL + Redis
- **SSL:** Let's Encrypt (renovação automática)

## Implantação Automatizada

A implantação em produção acontece automaticamente quando o código é enviado para a branch `main`:

1. **Execução de Testes** - RSpec (190 testes), RuboCop, Brakeman
2. **Scan de Segurança** - Bundler Audit  
3. **Deploy** - SSH no servidor, pull do código, migração do BD, reiniciar Puma
4. **Health Check** - Verificar endpoint /api/v1/health

## Implantação Manual

```bash
ssh deploy@161.35.142.103
cd /home/deploy/currency-converter-ruby/backend
git pull origin main
bundle install
RAILS_ENV=production rails db:migrate
sudo systemctl restart puma
```

## Configuração HTTPS

A aplicação está protegida com HTTPS usando um certificado SSL gratuito do Let's Encrypt.

### Passos da Configuração Inicial

1. **Configuração do Domínio:**
   - Domínio gratuito do DuckDNS: `currencyconverter.duckdns.org`
   - Apontado para o IP do servidor: `161.35.142.103`

2. **Instalação do Certbot:**
   ```bash
   sudo apt update
   sudo apt install certbot python3-certbot-nginx -y
   ```

3. **Configuração do Nginx:**
   - Atualizado `server_name` em `/etc/nginx/sites-available/currency-converter`
   - Alterado de IP para domínio: `currencyconverter.duckdns.org`

4. **Geração do Certificado SSL:**
   ```bash
   sudo certbot --nginx -d currencyconverter.duckdns.org
   ```
   
   O Certbot automaticamente:
   - Obtém certificado SSL do Let's Encrypt
   - Configura o Nginx para HTTPS
   - Configura redirecionamento de HTTP para HTTPS
   - Configura renovação automática

5. **Verificação:**
   ```bash
   curl https://currencyconverter.duckdns.org/api-docs
   ```

## Configuração de Ambiente

```bash
# Variáveis de ambiente necessárias
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@localhost/currency_converter_production
REDIS_URL=redis://localhost:6379/0
CURRENCY_API_KEY=your_api_key
DEVISE_JWT_SECRET_KEY=your_jwt_secret
SECRET_KEY_BASE=your_secret_key_base
```

## Stack do Servidor

**Servidor Web:** Nginx (reverse proxy)  
**Servidor de App:** Puma (2 workers, 5 threads)  
**Banco de Dados:** PostgreSQL 14  
**Cache:** Redis 7  

## Health Check

```bash
curl https://currencyconverter.duckdns.org/api/v1/health
```

Resposta esperada:
```json
{
  "status": "healthy",
  "services": {
    "database": {"status": "up"},
    "cache": {"status": "up"},
    "external_api": {"status": "configured"}
  }
}
```

## Pipeline CI/CD

Automatizado via GitHub Actions (`.github/workflows/ci-cd.yml`):
- Executa testes e scans de segurança a cada push
- Faz deploy em produção na branch main
- Verifica health check após o deployment

## Segurança

- ✅ Rate limiting (100 req/min)
- ✅ CORS configurado  
- ✅ Headers de segurança
- ✅ Scan automático de vulnerabilidades
- ✅ HTTPS com SSL Let's Encrypt
- ✅ Certificados SSL com renovação automática

## Gerenciamento de Certificado SSL

O certificado SSL é gerenciado pelo Let's Encrypt e renova automaticamente a cada 90 dias.

**Detalhes do Certificado:**
- Domínio: currencyconverter.duckdns.org
- Provedor: Let's Encrypt
- Localização: `/etc/letsencrypt/live/currencyconverter.duckdns.org/`
- Renovação automática: Configurada via Certbot

**Renovação Manual do SSL (se necessário):**
```bash
ssh deploy@161.35.142.103
sudo certbot renew
sudo systemctl reload nginx
```

**Testar Renovação Automática:**
```bash
sudo certbot renew --dry-run
```

## Monitoramento

- Logging JSON estruturado (Lograge)
- Detecção de requisições lentas (>1s)
- Métricas de performance por requisição
- Rastreamento de erros via Rails logger

---

**Configuração completa do CI/CD:** `.github/workflows/ci-cd.yml`
