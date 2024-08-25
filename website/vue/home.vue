<i18n>
{
  "en": {
    "HOME_TXT_Headline": "Home",
    "HOME_TXT_SwitchLanguage": "The language of the page can be switched here: ",
    "HOME_BTN_SwitchLanguage": "Switch language",
    "HOME_TXT_SectionTitle": "Section Title",
    "HOME_TXT_SectionContent": "This is the content of the section.",
    "HOME_IMG_Alt": "Image description",
    "HOME_TXT_AnotherSectionTitle": "Another Section Title",
    "HOME_TXT_AnotherSectionContent": "This is the content of another section.",
    "HOME_LIST_Item1": "List item 1",
    "HOME_LIST_Item2": "List item 2",
    "HOME_LIST_Item3": "List item 3"
  },
  "de": {
    "HOME_TXT_Headline": "Startseite",
    "HOME_TXT_SwitchLanguage": "Die Sprache der Seite kann hier umgeschaltet werden: ",
    "HOME_BTN_SwitchLanguage": "Sprache wechseln",
    "HOME_TXT_SectionTitle": "Abschnittstitel",
    "HOME_TXT_SectionContent": "Dies ist der Inhalt des Abschnitts.",
    "HOME_IMG_Alt": "Bildbeschreibung",
    "HOME_TXT_AnotherSectionTitle": "Titel eines anderen Abschnitts",
    "HOME_TXT_AnotherSectionContent": "Dies ist der Inhalt eines anderen Abschnitts.",
    "HOME_LIST_Item1": "Listenelement 1",
    "HOME_LIST_Item2": "Listenelement 2",
    "HOME_LIST_Item3": "Listenelement 3"
  }
}
</i18n>

<script>
export default {
  data() {
    return {
      imageUrl: 'img/image.jpg',
      listItems: [
        { id: 1, text: this.$t('HOME_LIST_Item1') },
        { id: 2, text: this.$t('HOME_LIST_Item2') },
        { id: 3, text: this.$t('HOME_LIST_Item3') }
      ]
    }
  },
  methods: {
    /**
    * Function to switch the language of the page.
    */
    switchLanguage() {
      this.$root.$i18n.locale = this.$root.$i18n.locale === 'en' ? 'de' : 'en';
    }
  },
  created() {
    console.log('Info: HomeComponent created()');
  },
  mounted() {
    console.log('Info: HomeComponent mounted()');
  }
}
</script>

<template>
  <div>
    <h1>{{ $t('HOME_TXT_Headline') }}</h1>
    <div style="display: flex; column-gap: 10px;">
      <div>{{ $t('HOME_TXT_SwitchLanguage') }}</div>
      <button class="button small" v-on:click="switchLanguage()">{{ $t('HOME_BTN_SwitchLanguage') }}</button>
    </div>
    <div>
      <h2>{{ $t('HOME_TXT_SectionTitle') }}</h2>
      <p>{{ $t('HOME_TXT_SectionContent') }}</p>
      <img :src="imageUrl" :alt="$t('HOME_IMG_Alt')" style="max-width: 100%;">
    </div>
    <div>
      <h2>{{ $t('HOME_TXT_AnotherSectionTitle') }}</h2>
      <p>{{ $t('HOME_TXT_AnotherSectionContent') }}</p>
      <ul>
        <li v-for="item in listItems" :key="item.id">{{ item.text }}</li>
      </ul>
    </div>
  </div>
</template>
