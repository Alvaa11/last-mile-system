import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum RouteStatus {
  PLANNED = 'PLANNED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

@Entity('routes')
export class Route {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User)
  driver: User;

  @Column('jsonb')
  optimizedSequence: number[]; // Array of delivery indices or IDs

  @Column('float', { nullable: true })
  totalDistance: number;

  @Column({
    type: 'enum',
    enum: RouteStatus,
    default: RouteStatus.PLANNED,
  })
  status: RouteStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
