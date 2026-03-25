import axios from 'axios';

const url = 'http://localhost:3000/routes/optimize';
const payload = {
  depot: { id: 'depot', latitude: -22.96583405165568, longitude: -47.19718271669482 },
  deliveries: [
    { id: 'entrega_1', latitude: -22.93490376317895, longitude: -47.162906968650454},
    { id: 'entrega_2', latitude: -22.976317327945264, longitude: -47.17609807255734 },
  ],
};

async function testOptimization() {
  try {
    const response = await axios.post(url, payload);
    console.log('--- Sequência Otimizada ---');
    console.log(JSON.stringify(response.data, null, 2));
  } catch (error) {
    // Type narrowing: Check if it's an Axios error
    if (axios.isAxiosError(error)) {
      console.error('Erro no teste (Axios):', error.response?.data || error.message);
    } 
    // Fallback: Check if it's a standard Error
    else if (error instanceof Error) {
      console.error('Erro no teste:', error.message);
    } 
    // Final fallback for unknown types
    else {
      console.error('Erro desconhecido:', error);
    }
  }
}

testOptimization();
