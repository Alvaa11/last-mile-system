 ## Cenario atual

 - J&T And Spoke Roterizador
 - App atual não faz rotas inteligentes. Constrói rotas sem sentido
 - A Empresa provedora desse app paga 50 reais por pessoa que utiliza
 - Utilizam 2 aplicativos, um para escanear os pacotes e outro para fazer as rotas

 ## Cenario desejado

 - Rotas inteligentes por proximidade
 - Um único aplicativo para escanear os pacotes e fazer as rotas
 
 
## Estado atual do projeto:

Por ora ele ainda não reconhece caminhos mais acessíveis para o endereço, por reconhecer somente longitude e latitude, o que faz com que ele construa rotas sem sentido.

Como por exemplo: 

endereços que entreguei:

{ id: 'depot', latitude: -22.96583405165568, longitude: -47.19718271669482 },
{ id: 'pagmenos john boyd', latitude: -22.93490376317895, longitude: -47.162906968650454},
{ id: 'Praça do Vida nova', latitude: -22.976317327945264, longitude: -47.17609807255734 },

retorno:

{ id: 'depot', latitude: -22.96583405165568, longitude: -47.19718271669482 },
{ id: 'Praça do Vida nova', latitude: -22.976317327945264, longitude: -47.17609807255734 },
{ id: 'pagmenos john boyd', latitude: -22.93490376317895, longitude: -47.162906968650454 }

Em relação a latitude e longitude sim, o endereço 2 é mais perto porém menos acessível, não há estrada que chegue lá, então se colocassemos os dois endereços no gps como paradas, e mantivessemos a rota, no meio do caminho para a entrega 2 iriamos passar em frente a entrega 1, e depois que fizessemos a entrega 2 iriamos ter que voltar para fazer a entrega 1. Acredito que com a evolução do projeto iremos conseguir fazer rotas mais inteligentes, levando em consideração não somente a latitude e longitude, mas também a acessibilidade dos endereços.