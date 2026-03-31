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
Object.defineProperty(exports, "__esModule", { value: true });
exports.DeliveryStatusHistory = void 0;
const typeorm_1 = require("typeorm");
const delivery_entity_1 = require("./delivery.entity");
let DeliveryStatusHistory = class DeliveryStatusHistory {
};
exports.DeliveryStatusHistory = DeliveryStatusHistory;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], DeliveryStatusHistory.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => delivery_entity_1.Delivery, { onDelete: 'CASCADE' }),
    __metadata("design:type", delivery_entity_1.Delivery)
], DeliveryStatusHistory.prototype, "delivery", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: delivery_entity_1.DeliveryStatus,
    }),
    __metadata("design:type", String)
], DeliveryStatusHistory.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'geography',
        spatialFeatureType: 'Point',
        srid: 4326,
        nullable: true,
    }),
    __metadata("design:type", String)
], DeliveryStatusHistory.prototype, "coords", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], DeliveryStatusHistory.prototype, "notes", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], DeliveryStatusHistory.prototype, "timestamp", void 0);
exports.DeliveryStatusHistory = DeliveryStatusHistory = __decorate([
    (0, typeorm_1.Entity)('delivery_status_history')
], DeliveryStatusHistory);
//# sourceMappingURL=delivery-status-history.entity.js.map