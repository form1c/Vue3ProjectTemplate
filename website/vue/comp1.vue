<i18n>
{
  "en": {
    "COMP1_TXT_Headline": "Welcome to Component 1",
    "COMP1_TXT_Description": "This is a demonstration of the first component in our application. It showcases the use of internationalization (i18n) and event emitting via the TinyEventBus. Hint: The TinyEventBus is only functional after component 2 has been mounted once. The output takes place on the console.",
    "COMP1_TXT_Test1": "Example text 1 for component 1",
    "COMP1_TXT_Test2": "Example text 2 for component 1",
    "COMP1_BTN_EmitEvent": "Emit Event"
  },
  "de": {
    "COMP1_TXT_Headline": "Willkommen bei Komponente 1",
    "COMP1_TXT_Description": "Dies ist eine Demonstration der ersten Komponente in unserer Anwendung. Sie zeigt die Verwendung von Internationalisierung (i18n) und das Senden von Ereignissen über den TinyEventBus. Hinweis: Der TinyEventBus ist erst funktionsfähig, nachdem Komponente 2 einmal gemounted wurde. Die Ausgabe erfolgt auf der Konsole.",
    "COMP1_TXT_Test1": "Beispieltext 1 für Komponente 1",
    "COMP1_TXT_Test2": "Beispieltext 2 für Komponente 1",
    "COMP1_BTN_EmitEvent": "Ereignis senden"
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
  data() {
    return {
      greeting: 'Greetings from Component1!',
      counter: 0
    }
  },
  methods: {
    /**
     * Emits a 'message' event via the TinyEventBus.
     * Input: None
     * Output: None
     */
    emitViaTinyEventBus() {
      this.emitter.emit('message', "Hello World from Component1 to Component2 via TinyEventBus: " + this.counter++);
    }
  },
  created() {
    console.log("Info: Component1 created() with props name: ", this.name);
  },
  mounted() {
    console.log("Info: Component1 mounted()");
  }
}
</script>

<template>
  <div>
    <h1 class="greeting">{{ $t('COMP1_TXT_Headline') }}</h1>
    <p>{{ $t('COMP1_TXT_Description') }}</p>
    <button class="button" v-on:click="emitViaTinyEventBus()">{{ $t('COMP1_BTN_EmitEvent') }}</button>
  </div>
</template>

<style>
.greeting {
  color: red;
  font-weight: bold;
}
</style>
