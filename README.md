# Projeto Terraform - Servidor Web AWS

Este projeto Terraform cria uma infraestrutura completa na AWS para hospedar um servidor web Apache em uma instância EC2.

## Recursos Criados

### Instância EC2

- **Tipo**: t2.micro (elegível para o nível gratuito)
- **AMI**: Ubuntu Server
- **Servidor Web**: Apache2 instalado automaticamente
- **Zona de Disponibilidade**: us-east-1a

### Rede

- **VPC**: Rede virtual privada com CIDR 10.0.0.0/16
- **Sub-rede**: Sub-rede pública com CIDR 10.0.1.0/24
- **Gateway de Internet**: Para acesso à internet
- **Tabela de Rotas**: Configurada para rotear tráfego para a internet

### Segurança

- **Grupo de Segurança**: Permite tráfego nas portas:
  - 80 (HTTP)
  - 22 (SSH)
  - 443 (HTTPS)

### IP e Interface de Rede

- **Interface de Rede**: IP privado fixo 10.0.1.50
- **IP Elástico**: IP público estático para acesso externo

## Pré-requisitos

1. **Terraform** instalado (versão compatível com provider AWS ~> 3.0)
2. **Conta AWS** ativa
3. **Par de chaves EC2** criado na região us-east-1
4. **Credenciais AWS** configuradas

## Configuração

Antes de executar, substitua os seguintes valores no arquivo `main.tf`:

```hcl
access_key = "my-access-key"     # Sua chave de acesso AWS
secret_key = "my-secret-key"     # Sua chave secreta AWS
key_name = "my-key-pair"         # Nome do seu par de chaves EC2
```

## Como Usar

1. **Inicializar o Terraform**:

   ```bash
   terraform init
   ```

2. **Planejar a execução**:

   ```bash
   terraform plan
   ```

3. **Aplicar a configuração**:

   ```bash
   terraform apply
   ```

4. **Confirmar** digitando `yes` quando solicitado

## Outputs

Após a aplicação bem-sucedida, você receberá:

- **IP Público**: Para acessar o servidor web
- **IP Privado**: IP interno da instância

## Acesso ao Servidor

Após a criação, você pode:

- Acessar o site em `http://[IP_PÚBLICO]`
- Conectar via SSH: `ssh -i sua-chave.pem ubuntu@[IP_PÚBLICO]`

## Limpeza

Para remover todos os recursos criados:

```bash
terraform destroy
```

## Variáveis

- `subnet_cidr`: CIDR da sub-rede (padrão: 10.0.1.0/24)

## Observações de Segurança

⚠️ **Importante**: Este exemplo usa credenciais hardcoded no código, o que não é recomendado para produção. Use variáveis de ambiente ou perfis AWS CLI.

## Estrutura do Projeto

```
project-1/
├── main.tf          # Configuração principal do Terraform
└── README.md        # Este arquivo
```
