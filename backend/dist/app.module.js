"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const config_1 = require("@nestjs/config");
const deliveries_module_1 = require("./deliveries/deliveries.module");
const users_module_1 = require("./users/users.module");
const auth_module_1 = require("./auth/auth.module");
const routes_module_1 = require("./routes/routes.module");
const tracking_module_1 = require("./tracking/tracking.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            typeorm_1.TypeOrmModule.forRoot({
                type: 'postgres',
                host: 'aws-1-us-west-1.pooler.supabase.com',
                port: 6543,
                username: 'postgres.jqscwqnmkutkmvtejdyw',
                password: 'Iamnotafraid1!',
                database: 'postgres',
                autoLoadEntities: true,
                synchronize: true,
                ssl: true,
                extra: {
                    ssl: {
                        rejectUnauthorized: false,
                    },
                },
                logging: ['error', 'warn'],
            }),
            auth_module_1.AuthModule,
            users_module_1.UsersModule,
            deliveries_module_1.DeliveriesModule,
            routes_module_1.RoutesModule,
            tracking_module_1.TrackingModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map