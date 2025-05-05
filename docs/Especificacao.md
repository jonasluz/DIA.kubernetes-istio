# ESPECIFICAÇÃO DA ATIVIDADE

## Requisitos

### Configuração do Ambiente:
- Configurem um repositório Git compartilhado para o projeto.
- Instalem e configurem a distribuição Kubernetes local escolhida em suas máquinas (ou em uma máquina compartilhada pela equipe). Certifiquem-se de alocar recursos suficientes (CPU/RAM).
- Instalem o Istio no cluster Kubernetes, utilizando o perfil de instalação demo ou default. Verifiquem a instalação.

### Implantação da Aplicação:
- Obtenham os manifestos de implantação da aplicação Online Boutique.
- Implantação base: implantem a aplicação sem a injeção automática de sidecars do Istio (ou seja, em um namespace sem o rótulo istio-injection=enabled). Verifiquem se todos os serviços estão rodando e se a aplicação está acessível .
- Implantação com Istio: habilitem a injeção automática de sidecars do Istio para um novo namespace (e.g., online-boutique-istio) e implantar a aplicação novamente neste namespace. Verifiquem se os sidecars foram injetados (kubectl get pods -n <namespace> -o wide deve mostrar 2/2 containers por pod) e se a aplicação continua acessível.

### Teste de Desempenho:
- Configurem a ferramenta de geração de carga escolhida(Locust ou k6). Criem um script de teste que simule a interação de usuários com a loja online (e.g., navegar por produtos, adicionar ao carrinho, finalizar compra). Dica: a aplicação Online Boutique já vem com um script para realizar testes de carga com o Locust.
- Teste sem Istio: executem o teste de carga contra a versão da aplicação sem os sidecars do Istio (implantação base). Coletem métricas como latência média/percentil 95/99 e vazão (requisições por segundo).
- Teste com Istio: executem o mesmo teste de carga, com a mesma intensidade, contra a versão da aplicação com os sidecars do Istio (implantação com Istio). Coletem as mesmas métricas.
- Análise de overhead: comparem os resultados dos dois testes. Analisem e quantifiquem o overhead (diferença) de desempenho (latência e/ou vazão) introduzido pelo Istio. Discutam possíveis causas para o overhead observado.

### Teste de Resiliência:
- Utilizando os recursos de VirtualService e/ou DestinationRule do Istio, configurem regras de injeção de falhas.
- Injeção de atraso: injetem um atraso significativo (e.g., 2 segundos) nas respostas de um serviço interno crítico, mas não essencial para a funcionalidade básica (e.g., recommendation ou ad). Observem (manualmente ou via logs/métricas) como a aplicação se comporta. A interface do usuário ainda funciona? O desempenho degrada gradualmente?
- Injeção de erro: Injetem erros HTTP (e.g., 503 Service Unavailable) em uma porcentagem das requisições (e.g., 25% e 50%) para outro serviço (e.g., productcatalog). Observem o comportamento da aplicação. Ela consegue lidar com falhas parciais? Descrevam os mecanismos de resiliência (ou a falta deles) observados.
- Documentem as configurações do Istio utilizadas e os comportamentos observados em cada cenário de falha.

### Teste de Desempenho com Escalonamento Automático:
- Configurem o Horizontal Pod Autoscaler (HPA) do Kubernetes para um ou mais serviços que sejam gargalos potenciais sob carga (e.g., frontend, productcatalog, checkout). Definam métricas de alvo (e.g., utilização de CPU em 70%). Certifiquem-se que os requisitos de recursos (CPU/memória) estão definidos nos manifestos de implantação dos serviços alvos para o HPA funcionar corretamente.
- Teste com HPA: executem um teste de carga (usando Locust/k6) com intensidade crescente ou sustentada que seja suficiente para disparar o escalonamento automático. Monitorem o número de pods do(s) serviço(s) com HPA. Coletem métricas de desempenho (latência, vazão) durante o teste.
- Análise dos resultados: comparem o desempenho (latência, vazão) sob carga com o HPA habilitado versus um cenário com um número fixo de réplicas (pode ser o resultado do teste de desempenho com Istio, se a carga for comparável, ou um novo teste de controle). Analisem a eficácia do HPA em manter o desempenho e lidar com a variação de carga. Discutam os limites e desafios do escalonamento automático.

## Entregas

### Entrega Parcial 1: Configuração e Implantação
- Foco: Tarefas 1 e 2 
#### Entregáveis:
- Relatório Preliminar (2-3 páginas,) incluindo:
- Formação da equipe e link para o repositório Git criado.
- Evidência do sucesso (e.g., screenshots, logs) na instalação e configuração do ambiente Kubernetes local (incluir versão, recursos alocados).
- Evidência do sucesso (e.g., screenshots, logs) na instalação do Istio (incluir versão, perfil utilizado).
- Evidência do sucesso (e.g., screenshots, logs) na implantação da aplicação Online Boutique nos dois cenários (sem e com injeção do sidecar Istio).
- Repositório Git atualizado com a estrutura inicial e quaisquer scripts/manifestos básicos utilizados.

### Entrega Parcial 2: Teste de Desempenho e Análise de Overhead
- Foco: Tarefa 3 
#### Entregáveis:
- Uma seção atualizada do relatório descrevendo:
- Metodologia do teste de desempenho (ferramenta escolhida, script de teste, intensidade da carga, duração).
- Resultados dos testes de desempenho (tabelas/gráficos comparando latência e vazão com e sem Istio).
- Análise preliminar do overhead de desempenho introduzido pelo Istio.
- Repositório Git atualizado contendo os scripts de teste de carga utilizados e os manifestos relevantes da aplicação (se modificados).

### Entrega Parcial 3: Testes de Resiliência e Escalonamento Automático
- Foco: Tarefas 4 e 5 
#### Entregáveis:
- Uma seção atualizada do relatório descrevendo:
- Metodologia dos testes de injeção de falhas (configurações do Istio, cenários testados).
- Observações e análise do comportamento da aplicação sob falha injetada.
- Configuração do HPA (manifestos YAML).
- Metodologia do teste de desempenho com HPA (carga aplicada).
- Resultados do teste com HPA (gráficos mostrando número de pods ao longo do tempo, métricas de desempenho sob carga).
- Análise preliminar da eficácia do HPA.
- Repositório Git atualizado contendo os manifestos YAML do Istio para injeção de falhas, os manifestos do HPA e quaisquer outros artefatos relevantes..

### Entrega Final: Relatório Consolidado e Repositório Completo
- Foco: Integração, refinamento e conclusões 
#### Entregáveis:
- Relatório Técnico Final: versão completa e revisada do relatório, integrando todas as seções anteriores (Introdução, Configuração, Metodologias, Resultados, Análise e Discussão aprofundada comparando todos os experimentos, conclusões gerais, e dificuldades). 
- Repositório Git Final: Link para o repositório Git finalizado, contendo todo o código, scripts, manifestos YAML, e um arquivo README.md explicando como replicar os experimentos.