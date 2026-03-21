import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Delivery, DeliveryStatus } from './entities/delivery.entity';
import { DeliveryStatusHistory } from './entities/delivery-status-history.entity';
import { CreateDeliveryDto, UpdateDeliveryDto } from './dto/delivery.dto';

@Injectable()
export class DeliveriesService {
  constructor(
    @InjectRepository(Delivery)
    private readonly repository: Repository<Delivery>,
    @InjectRepository(DeliveryStatusHistory)
    private readonly historyRepository: Repository<DeliveryStatusHistory>,
  ) {}

  async create(createDeliveryDto: CreateDeliveryDto): Promise<Delivery> {
    const delivery = this.repository.create(createDeliveryDto);
    return this.repository.save(delivery);
  }

  async findAll(): Promise<Delivery[]> {
    return this.repository.find({ order: { priority: 'DESC', createdAt: 'DESC' } });
  }

  async findOne(id: string): Promise<Delivery> {
    const delivery = await this.repository.findOneBy({ id });
    if (!delivery) throw new NotFoundException(`Delivery with ID ${id} not found`);
    return delivery;
  }

  async update(id: string, updateDto: UpdateDeliveryDto): Promise<Delivery> {
    const delivery = await this.findOne(id);
    
    if (updateDto.status && updateDto.status !== delivery.status) {
      // Audit status change
      await this.historyRepository.save(
        this.historyRepository.create({
          delivery,
          status: updateDto.status,
          coords: updateDto.currentCoords
        })
      );
      delivery.status = updateDto.status;
    }

    Object.assign(delivery, updateDto);
    return this.repository.save(delivery);
  }

  async remove(id: string): Promise<void> {
    const delivery = await this.findOne(id);
    await this.repository.remove(delivery);
  }
}
