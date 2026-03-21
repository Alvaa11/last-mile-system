# FRONTEND

"Atue como um Engenheiro de Software Sênior especializado em Flutter e Clean Architecture. Gere o código completo para um aplicativo de entrega Last Mile focado em alta produtividade para motoristas.
Contexto e Objetivo: O app deve gerenciar o ciclo de vida diário do entregador: autenticação, escaneamento de pacotes no hub, visualização de lista otimizada, navegação e prova de entrega digital (ePOD)
.
Arquitetura Técnica:
Clean Architecture: Camadas estritamente separadas em data, domain e presentation.
Gerenciamento de Estado: Bloc (Business Logic Component).
Offline-First: Implementar uma 'Changes Queue' para salvar ações localmente (SQLite ou Hive) e sincronizar via Delta Synchronization assim que a conexão for restaurada
.
Funcionalidades Obrigatórias:
Auth: Login JWT com persistência segura de token.
Escaneamento em Lote: Tela de câmera integrada para leitura sequencial rápida de QR Codes/Barcodes (padrão GS1-128). Exiba um overlay visual de feedback imediato após cada scan bem-sucedido
.
Lista de Entregas Dinâmica: Exibição clara com Nome, Endereço e Status. Implemente ordenação dinâmica.
Otimização de Rota: Botão que consome o endpoint do backend para reordenar a sequência de paradas com base no menor tempo/distância
.
Navegação Integrada: Uso do google_maps_flutter para exibir a rota. O motorista deve conseguir iniciar a navegação sem sair do app
.
Confirmação (ePOD): Captura de foto e observação. Use Geofencing para validar se o motorista está no raio correto do destino antes de permitir a conclusão (mínimo de 100m)
.
UI/UX:
Design de alta legibilidade para uso sob luz solar.
Botões grandes para operação com uma mão e baixo esforço cognitivo
.
Paleta de cores de alto contraste.
Estrutura de Pastas Esperada:
lib/core (errors, network, usecases, local_storage).
lib/features (auth, scanner, delivery_list, map_navigation).
Cada feature deve conter suas subpastas data, domain e presentation."

# BACKEND

"Atue como Arquiteto de Soluções Cloud e Especialista em IA. Gere a infraestrutura de backend para um sistema de roteirização inteligente de última milha.
Tecnologias:
Core: NestJS (TypeScript).
Banco de Dados: PostgreSQL com extensão PostGIS para consultas geoespaciais e armazenamento de pontos/polígonos
.
IA/Otimização: Microserviço em Python para resolver o Problema de Roteamento de Veículos (VRP)
.
Requisitos do Backend (NestJS):
Módulos: Auth (JWT/Passport), Deliveries (CRUD e estados: Pendente, Em Rota, Entregue, Falhou), Users, Routing.
Real-Time: Implementar WebSockets para atualizações de telemetria de GPS em tempo real e sincronização de status para o cliente final
.
Integração de Mapas: Consumo de APIs do Google Distance Matrix ou Mapbox para obter matrizes de tempo/distância reais
.
Sincronização Delta: Endpoint específico para receber a fila de mudanças pendentes do app mobile e resolver conflitos de dados (estratégia Last Write Wins)
.
Microserviço de IA (Python):
Utilize a biblioteca Google OR-Tools ou PyVRP para calcular a sequência ótima de entregas
.
O algoritmo deve considerar: Janelas de tempo do cliente, capacidade do veículo (CVRP) e prioridade de entrega
.
Implemente uma API simples (FastAPI ou Flask) para receber a lista de endereços e retornar a sequência ordenada de IDs.
Esquema de Banco de Dados:
Tabela deliveries com colunas de geography(Point, 4326) para coordenadas precisas.
Tabela delivery_logs para auditoria de cada mudança de status com timestamp e geolocalização do motorista
.
Entrega Esperada:
Código modular, documentação de API via Swagger e scripts de migração do banco de dados."

🧠 Arquitetura do Sistema
O sistema segue uma arquitetura de microserviços desacoplados, onde o NestJS gerencia as regras de negócio e persistência, enquanto o Python atua como um motor de cálculo intensivo para o Problema de Roteamento de Veículos (VRP)
.
Estrutura de Pastas Sugerida
/last-mile-root
  /backend-nestjs (API Principal)
    /src
      /auth (JWT, Strategy)
      /deliveries (Scan, CRUD, Geocoding)
      /routes (Integração com Python)
      /tracking (WebSockets)
      /common (Database, PostGIS config)
  /optimizer-python (Microserviço IA)
    /app
      main.py (FastAPI)
      solver.py (Heurísticas/OR-Tools)
  /docker-compose.yml

--------------------------------------------------------------------------------
🗄️ Modelagem do Banco de Dados (PostgreSQL + PostGIS)
Para suportar operações geoespaciais avançadas, como geofencing e cálculos de distância, utilizaremos a extensão PostGIS
.
Entidades Principais:
Users: id, email, password_hash, role (driver/admin), current_location (geography)
.
Deliveries: id, customer_name, address, location (geography), status, priority, qr_code_id, weight/volume
.
Routes: id, driver_id, optimized_sequence (jsonb/int[]), total_distance, status
.
DeliveryStatusHistory: id, delivery_id, status, timestamp, coords (geography)
.

--------------------------------------------------------------------------------
📦 Funcionalidades e Implementação
1. Integração com QR Code e Scan
O sistema suporta duas estratégias de processamento de pacotes
:
Identifier-Only: O scan lê apenas um ID (ex: SSCC via AI 00) e o NestJS busca os metadados (endereço, cliente) no banco de dados central
.
Data-Heavy: O código (QR ou DataMatrix) contém o payload completo comprimido, permitindo a triagem inicial e roteirização básica mesmo em áreas com "zero sinal" (cânions urbanos)
.
2. Roteirização (Core)
O NestJS envia uma lista de coordenadas para o microserviço Python. A ordem otimizada minimiza a distância total e respeita janelas de tempo (Time Windows)
.
Microserviço Python (Heurística TSP/VRP): Utilizamos o Google OR-Tools ou PyVRP para resolver o problema de forma eficiente em segundos

"# optimizer-python/app/solver.py (Exemplo simplificado)
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp

def solve_vrp(distance_matrix, num_vehicles, depot_index):
    manager = pywrapcp.RoutingIndexManager(len(distance_matrix), num_vehicles, depot_index)
    routing = pywrapcp.RoutingModel(manager)
    
    def distance_callback(from_index, to_index):
        return distance_matrix[manager.IndexToNode(from_index)][manager.IndexToNode(to_index)]
    
    transit_callback_index = routing.RegisterTransitCallback(distance_callback)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)
    
    # Adiciona dimensão de distância para otimizar o percurso [20, 21]
    routing.AddDimension(transit_callback_index, 0, 30000, True, 'Distance')
    
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC
    
    solution = routing.SolveWithParameters(search_parameters)
    # Retorna a sequência de IDs otimizada para o NestJS
3. Geolocalização e Geofencing
A conversão de endereço em lat/long (geocoding) utiliza Mapbox ou Google Maps API
. Para validar a entrega, o sistema aplica a Fórmula de Haversine via WebSocket para garantir que o entregador está dentro de um raio de segurança (ex: 100m) antes de permitir a conclusão da entrega (Proof of Delivery)
.
4. Tempo Real (WebSockets)
O NestJS utiliza o @nestjs/websockets para:
Telemetry Layer: Receber atualizações de GPS do entregador a cada 5-10 segundos
.
Customer Visibility: Notificar o cliente quando o motorista está a "5 minutos de distância", reduzindo falhas na primeira tentativa de entrega
.

--------------------------------------------------------------------------------
📡 Integração entre Serviços
O fluxo de comunicação é síncrono para roteirização e assíncrono para logs:
NestJS → Python (HTTP POST): Envia as coordenadas das entregas pendentes.
Python → NestJS (JSON Response): Retorna o array de índices ordenados para a rota
.
NestJS → Driver App: Atualiza a interface com a navegação curva-a-curva otimizada
.
🚀 Diferenciais de Escalabilidade
Offline-First: O app do entregador realiza atualizações otimistas na interface local e sincroniza as "deltas" assim que recupera a conexão em áreas de sombra de sinal
.
Cânions Urbanos: Preparado para integrar modelos de peso SNR para mitigar erros de GPS em centros urbanos densos
.
IA de Dwell Time: O microserviço Python pode evoluir para aprender o tempo real de espera em prédios específicos, refinando os ETAs em até 98% de precisão
.