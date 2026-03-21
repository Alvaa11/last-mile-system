import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { DeliveriesModule } from './deliveries/deliveries.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { RoutesModule } from './routes/routes.module';
import { TrackingModule } from './tracking/tracking.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 5432,
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres_password',
      database: process.env.DB_DATABASE || 'lastmile_db',
      autoLoadEntities: true,
      synchronize: true, // Warn: Only for development
      logging: ['error', 'warn'],
    }),
    AuthModule,
    UsersModule,
    DeliveriesModule,
    RoutesModule,
    TrackingModule,
  ],
})
export class AppModule {}
