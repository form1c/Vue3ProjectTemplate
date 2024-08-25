class TinyEventBus {
    constructor() {
        this.events = {};
    }
    on(eventName, callback) {
        if (!this.events[eventName]) {
            this.events[eventName] = [];
        }
        this.events[eventName].push(callback);
        return () => this.off(eventName, callback);
    }
    off(eventName, callback) {
        if (this.events[eventName]) {
            this.events[eventName] = this.events[eventName].filter((cb) => cb !== callback);
        }
    }
    emit(eventName, ...args) {
        if (this.events[eventName]) {
            this.events[eventName].forEach((callback) => callback(...args));
        }
    }
}

