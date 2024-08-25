<i18n>
{
  "en": {
   "TOPMENU_BTN_HOME":"Go to Home",
   "TOPMENU_BTN_COMP1":"Go to Component 1",
   "TOPMENU_BTN_COMP2":"Go to Component 2"
  },
  "de": {
    "TOPMENU_BTN_HOME":"Zur Startseite",
    "TOPMENU_BTN_COMP1":"Zur Komponente 1",
    "TOPMENU_BTN_COMP2":"Zur Komponente 2"
  }
}
</i18n>

<script>
export default {
  data() {
    return {
      allFilesLoaded: false
    }
  },
  methods: {
    registerTinyEventBusReceiver() {
      var self = this;
      const handleAllFilesLoaded = (data) => {
        console.log("Info: All Files Loaded. Result: "+data)
        self.allFilesLoaded = data;
      };
      this.emitter.off('loaderdone', handleAllFilesLoaded);
      this.emitter.on('loaderdone', handleAllFilesLoaded);
    }
  },
  created() {
    console.log('Info: Top-Menu created()');
    this.registerTinyEventBusReceiver();
  },
  mounted() {
    console.log('Info: Top-Menu mounted()');
  }
}
</script>

<template>
  <div style="display: flex; column-gap: 10px;">
    <!-- Use router-link instead of manual navigation -->
    <router-link to="/">
      <button id="IdBtnHome" class="button">{{$t('TOPMENU_BTN_HOME')}}</button>
    </router-link>
    <router-link to="/comp1">
      <button id="IdBtnComp1" class="button">{{$t('TOPMENU_BTN_COMP1')}}</button>
    </router-link>
    <!-- Only show the button if the 'comp2' component is loaded -->
    <template v-if="allFilesLoaded">
      <router-link to="/comp2">
        <button id="IdBtnComp2" class="button">{{$t('TOPMENU_BTN_COMP2')}}</button>
      </router-link>
    </template>
  </div>
</template>
