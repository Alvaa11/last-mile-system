"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./src/app.module");
const deliveries_service_1 = require("./src/deliveries/deliveries.service");
async function bootstrap() {
    console.log('Starting standalone NestJS context...');
    try {
        const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
        console.log('Context created successfully.');
        const service = app.get(deliveries_service_1.DeliveriesService);
        console.log('DeliveriesService obtained. Fetching...');
        try {
            const list = await service.findAll();
            console.log('SUCCESS! Found', list.length, 'deliveries');
            console.log(list);
        }
        catch (e) {
            console.error('EXCEPTION during findAll():');
            console.error(e);
        }
        await app.close();
    }
    catch (e) {
        console.error('Failed to create context:', e);
    }
}
bootstrap();
//# sourceMappingURL=test-db.js.map