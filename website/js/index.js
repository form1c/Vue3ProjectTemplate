/**************************************************/
/* Router                                         */
/**************************************************/
// Define the routes for the application
const routes = [
  { path: '/', component: { template: '<div><home></home></div>' } },
  { path: '/comp1', component: { template: '<div><comp1 name="SimpleComp1"></comp1></div>' } }
]

// Create the Vue Router instance
const router = VueRouter.createRouter({
  history: VueRouter.createWebHashHistory(),
  routes, // short for `routes: routes`
})

/**************************************************/
/* i18n                                           */
/**************************************************/
// Create the Vue 3 i18n instance
const i18n = VueI18n.createI18n({
  allowComposition: false,
  legacy: false,
  globalInjection: true,
  locale: 'en',
  fallbackLocale: 'en',
  messages: { en: { "welcome": 'Welcome application!' },
              de: { "welcome": 'Willkommen Anwendung!' } }
})

/**************************************************/
/* Vuex                                           */
/**************************************************/
// Create the Vuex store
const store = new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment(state) {
      state.count++
    },
    decrement(state) {
      state.count--
    }
  }
})

/**************************************************/
/* Vue App                                        */
/**************************************************/
// Create the Vue 3 application
const app = Vue.createApp({
  el: '#app',
  router: router,
  i18n: i18n,
  store: store,
  setup() {
    const { t } = VueI18n.useI18n()
    return { t }
  },
  data() {
    return {

    }
  },
  methods: {
    /**************************************************/
    /* Vuex Test Functions                            */
    /**************************************************/
    /**
     * Tests the Vuex store by committing the 'increment' and 'decrement' mutations.
     * Input: None
     * Output: None
     */
    testVuexStore() {
      const self = this;
      store.commit('increment')
      console.log("Info: vuex store increment (+1): " + store.state.count) // -> 1
      store.commit('decrement')
      console.log("Info: vuex store decrement (-1): " + store.state.count) // -> 0
      // or
      self.increment();
    },
    /**
     * Commits the 'increment' mutation to the Vuex store.
     * Input: None
     * Output: None
     */
    increment() {
      const self = this;
      self.$options.store.commit('increment')
      console.log("Info: vuex store increment (+1): " + self.$options.store.state.count)
    },
    /**************************************************/
    /* Vue3 Emit Handler                              */
    /**************************************************/
    /**
     * Handles the 'counterUpdated' event emitted from a child component.
     * Updates the content of an element with the ID 'IdVue3ReceiverOutput'.
     * Input: counter (the value emitted with the event)
     * Output: None
     */
    handleVue3Event(counter) {
      console.log("Info: Vue3 App (main) received counter: " + counter)
      document.getElementById('IdVue3ReceiverOutput').textContent = counter;
    },
    /**************************************************/
    /* Load vue.js file dynamically                   */
    /**************************************************/
    /**
     * Dynamically loads the 'comp2.vue.js' file and adds a new route for the component.
     * Input: None
     * Output: None
     */
    loadVueComponents() {
      const self = this;
      TinyLoader.embedFile("/vue/comp2.vue.js")
      .then((results) => {
        console.log("Info: vue/comp2.vue.js loaded successfully!");
        router.addRoute({ path: '/comp2', component: { template: '<div><comp2></comp2></div>' } });
        self.emitAllFilesLoaded(true);
      })
      .catch((error) => {
        console.log("Error: An error occurred when loading the file.");
        self.emitAllFilesLoaded(false);
      });
    },
    emitAllFilesLoaded(state) {
      this.emitter.emit('loaderdone', state);
    }
  },
  /**************************************************/
  /* VUE Functions                                  */
  /**************************************************/
  created() {
  },
  mounted() {
    const self = this;

    // Test Vuex store
    self.testVuexStore()

    // Load vue.js component dynamically
    self.loadVueComponents();
  }
})

// Use the router, i18n, and store in the Vue application
app.use(router)
app.use(i18n)
app.use(store)

// Create a global event bus
const eventBus = new TinyEventBus();
app.config.globalProperties.emitter = eventBus;

// Execute this function if the complete page is loaded
document.onreadystatechange = () => {
  if (document.readyState == "complete") {
    app.mount('#app')  // Mount the Vue application after all files are loaded
  }
}
