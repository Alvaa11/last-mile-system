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
    AuthModule,
    UsersModule,
    DeliveriesModule,
    RoutesModule,
    TrackingModule,
  ],
})
export class AppModule {
  constructor() {
    console.log('AppModule initialization');
  }
}
