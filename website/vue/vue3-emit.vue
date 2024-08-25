<i18n>
{
  "en": {
    "VUE3EMIT_HDL_PageTitle": "Vue3 Emit Example",
    "VUE3EMIT_BTN_EmitEvent": "Vue3 Emit Event",
    "VUE3EMIT_LBL_Counter": "Event counter of sender: {count}",
    "VUE3EMIT_DESC_Component": "This is a Vue3 component that demonstrates the use of Vue3 event emitting. The component has a button that, when clicked, emits an event with the current counter value. The counter is incremented after each event emission."
  },
  "de": {
    "VUE3EMIT_HDL_PageTitle": "Vue3 Ereignis-Beispiel",
    "VUE3EMIT_BTN_EmitEvent": "Vue3 Ereignis senden",
    "VUE3EMIT_LBL_Counter": "Ereigniszähler des Absenders: {count}",
    "VUE3EMIT_DESC_Component": "Dies ist eine Vue3-Komponente, die die Verwendung von Vue3 Ereignisemittierung demonstriert. Die Komponente hat eine Schaltfläche, die beim Klicken ein Ereignis mit dem aktuellen Zählerwert sendet. Der Zähler wird nach jeder Ereignisemission erhöht."
  }
}
</i18n>

<script>
export default {
  props: {
    /**
     * The props name of the component.
     */
    name: {
      type: String,
      required: true
    }
  },
  emits: ['counterupdated'],
  data() {
    return {
      /**
       * The counter value that is emitted with the event.
       */
      counter: 0
    }
  },
  methods: {
    /**
     * Emits the 'counterupdated' event with the current counter value.
     * The counter is incremented after the event is emitted.
     * Input: None
     * Output: None
     */
    emitVue3Event() {
      ++this.counter
      console.log("Info: Vue3EmitExample emit counter: " + this.counter)
      this.$emit("counterupdated", this.counter )
    }
  },
  created() {
    console.log("Info: Vue3EmitExample component created")
  },
  mounted() {
    console.log("Info: Vue3EmitExample component mounted")
  }
}
</script>

<template>
  <div>
    <h2>{{ $t('VUE3EMIT_HDL_PageTitle') }}</h2>
    <p>{{ $t('VUE3EMIT_DESC_Component') }}</p>
    <p>{{ $t('VUE3EMIT_LBL_Counter', { count: counter }) }}</p>
    <button class="button small" v-on:click="emitVue3Event()">{{ $t('VUE3EMIT_BTN_EmitEvent') }}</button>
  </div>
</template>
