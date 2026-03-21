"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DeliveriesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const delivery_entity_1 = require("./entities/delivery.entity");
const delivery_status_history_entity_1 = require("./entities/delivery-status-history.entity");
let DeliveriesService = class DeliveriesService {
    constructor(repository, historyRepository) {
        this.repository = repository;
        this.historyRepository = historyRepository;
    }
    async create(createDeliveryDto) {
        const delivery = this.repository.create(createDeliveryDto);
        return this.repository.save(delivery);
    }
    async findAll() {
        return this.repository.find({ order: { priority: 'DESC', createdAt: 'DESC' } });
    }
    async findOne(id) {
        const delivery = await this.repository.findOneBy({ id });
        if (!delivery)
            throw new common_1.NotFoundException(`Delivery with ID ${id} not found`);
        return delivery;
    }
    async update(id, updateDto) {
        const delivery = await this.findOne(id);
        if (updateDto.status && updateDto.status !== delivery.status) {
            await this.historyRepository.save(this.historyRepository.create({
                delivery,
                status: updateDto.status,
                coords: updateDto.currentCoords
            }));
            delivery.status = updateDto.status;
        }
        Object.assign(delivery, updateDto);
        return this.repository.save(delivery);
    }
    async remove(id) {
        const delivery = await this.findOne(id);
        await this.repository.remove(delivery);
    }
};
exports.DeliveriesService = DeliveriesService;
exports.DeliveriesService = DeliveriesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(delivery_entity_1.Delivery)),
    __param(1, (0, typeorm_1.InjectRepository)(delivery_status_history_entity_1.DeliveryStatusHistory)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], DeliveriesService);
//# sourceMappingURL=deliveries.service.js.map