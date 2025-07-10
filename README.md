
# Case: Software Engineer 

Esse projeto implementa uma API na AWS que preve a probabilidade de sobrevivencia de passageiros com base em um modelo de Machine Learning treinado no dataset do Titanic. a infraestrutura foi criada com Terraform e testada com Insomnia.

---

## ⚠️ Atenção
|
O código de infra contém o **número da conta AWS chumbado (437945666329)**

---

## Como subir

```bash
terraform init
terraform apply
```

---

## Como testar

A API foi testada usando o Insomnia, com esse endpoint base:

```txt
https://ok2vuwpnjd.execute-api.sa-east-1.amazonaws.com/sobreviventes
```

---

## Rotas da API

### `POST /sobreviventes`

- **Descrição:** Envia os dados de um passageiro e retorna a probabilidade de sobrevivência. 
                 As feature em questão são essas aqui: Pclass, Sex, Age, SibSp, Parch, Fare, Embarked
- **Payload de exemplo:**

```json
{
  "passenger_id": "123",
  "features": [29.0, 1, 0, 7.25, 3, 0, 1, 1]
}
```

- **Resposta esperada:**

```json
{
  "passenger_id": "123",
  "probability": 0.8125
}
```

---

### `GET /sobreviventes`

- **Descrição:** Lista todos os passageiros e suas probabilidades que já foram registradas.
- **Resposta esperada:**

```json
[
  {
    "passenger_id": "123",
    "probability": 0.8125
  },
  {
    "passenger_id": "124",
    "probability": 0.3821
  }
]
```

---

### `GET /sobreviventes/{id}`

- **Descrição:** Retorna a probabilidade de um passageiro específico que já foi registrado
- **Exemplo de requisição:**

```txt
GET /sobreviventes/123
```

- **Resposta esperada:**

```json
{
  "passenger_id": "123",
  "probability": 0.8125
}
```

---

### `DELETE /sobreviventes/{id}`

- **Descrição:** Deleta um passageiro.
- **Exemplo de requisição:**

```txt
DELETE /sobreviventes/123
```

- **Resposta esperada:**

```json
{
  "message": "Passageiro 123 deletado com sucesso"
}
```

---

