import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DeliveriesService } from './deliveries/deliveries.service';

async function bootstrap() {
  console.log('Starting standalone NestJS context...');
  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    console.log('Context created successfully.');
    const service = app.get(DeliveriesService);
    console.log('DeliveriesService obtained. Fetching...');
    try {
      const list = await service.findAll();
      console.log('SUCCESS! Found', list.length, 'deliveries');
      console.log(list);
    } catch (e) {
      console.error('EXCEPTION during findAll():');
      console.error(e);
    }
    await app.close();
  } catch(e) {
    console.error('Failed to create context:', e);
  }
}
bootstrap();
