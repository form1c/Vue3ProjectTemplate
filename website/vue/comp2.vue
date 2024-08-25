<i18n>
{
  "en": {
    "COMP2_TXT_Headline": "Welcome to Component 2",
    "COMP2_TXT_Description": "This is a demonstration of the second component in our application. It showcases the use of internationalization (i18n), event handling, and the TinyEventBus integration.",
    "COMP2_TXT_Test1": "Example text 1 for component 2",
    "COMP2_TXT_Test2": "Example text 2 for component 2",
    "COMP2_BTN_AlertClick": "Click me to trigger an alert"
  },
  "de": {
    "COMP2_TXT_Headline": "Willkommen bei Komponente 2",
    "COMP2_TXT_Description": "Dies ist eine Demonstration der zweiten Komponente in unserer Anwendung. Sie zeigt die Verwendung von Internationalisierung (i18n), Ereignisverarbeitung und die Integration des TinyEventBus.",
    "COMP2_TXT_Test1": "Beispieltext 1 für Komponente 2",
    "COMP2_TXT_Test2": "Beispieltext 2 für Komponente 2",
    "COMP2_BTN_AlertClick": "Klicke mich, um einen Alarm auszulösen"
  }
}
</i18n>

<script>
export default {
  data() {
    return {
      greeting: 'Greetings from Component2!'
    }
  },
  methods: {
    /**
     * Displays an alert with the provided data.
     * Input: String
     * Output: None
     */
    alertClickFunction(data) {
      alert(data);
    },
    /**
     * Registers a TinyEventBus receiver for the 'message' event.
     * Input: None
     * Output: None
     */
    registerTinyEventBusReceiver() {
      const handleReceivedEvent = (data) => {
        console.log("Info: TinyEventBus received: " + data);
      };
      this.emitter.off('message', handleReceivedEvent);
      this.emitter.on('message', handleReceivedEvent);
    }
  },
  created() {
    console.log("Info: Component2 created()");
  },
  mounted() {
    console.log("Info: Component2 mounted()");
    this.registerTinyEventBusReceiver();
  }
}
</script>

<template>
  <div class="my-css-class" style="my-html-style" comment="my-html-comment">
    <h1 class="greeting2">{{ $t('COMP2_TXT_Headline') }}</h1>
    <p>{{ $t('COMP2_TXT_Description') }}</p>
    <p class="hallo-p-class">{{ $t('COMP2_TXT_Test1') }}</p>
    <p class="hallo-p-class">{{ $t('COMP2_TXT_Test2') }}</p>
    <button class="button" v-on:click="alertClickFunction('Component2 Button Click!')">{{ $t('COMP2_BTN_AlertClick') }}</button>
  </div>
</template>

<style>
.greeting2 {
  color: green;
  font-weight: bold;
}
.hallo-p-class {
  color: yellowgreen;
}
</style>
