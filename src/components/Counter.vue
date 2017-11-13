<template>
  <div class="app">
    <div class="question">
      Studiert {{ name }} noch?
    </div>

    <div class="answer">
      <div v-if="finished" class="false">
        <span>Nein!</span>
        <img
          class="emoji"
          draggable="false"
          src="https://twemoji.maxcdn.com/72x72/1f389.png"/>
      </div>
      <div v-else class="true">
        <span>JA!</span>
        <img
          class="emoji"
          draggable="false"
          src="https://twemoji.maxcdn.com/72x72/231b.png"/>

        <div class="counter">
          Schon {{ counter }}.
        </div>
      </div>
    </div>

    <div class="presents">
      Proudly presented by NPM, Vue.js, webpack, Babel, uglifyjs, ES6, CSS3, HTML5, SASS, Docker, Nginx, Let's Encrypt, countdownjs, IndieFlower, Twitter Emojies, Fin and Johann
    </div>
  </div>
</template>

<script>
  import countdown from 'countdown'
  import config from '../config'
  import ForkMe from 'fork-me-github'

  countdown.setLabels(
    ' Millisekunde| Sekunde| Minute| Stunde| Tag| Woche| Monat| Jahr| Dekade| Jahrhundert',
    ' Millisekunden| Sekunden| Minuten| Stunden| Tage| Wochen| Monate| Jahre| Dekaden| Jahrhunderte',
    ' und '
  )

  var data = {
    name: config.name,
    counter: '',
    finished: config.finished
  }

  export default {
    name: 'Counter',
    created () {
      ForkMe('https://github.com/johannwagner/studierteriknoch')
      document.title = `Studiert ${data.name} noch?`
      data.counter = countdown(config.start).toString()

      setInterval(() => {
        data.counter = countdown(config.start).toString()
      }, 1000)
    },
    data () {
      return data
    }
  }
</script>

<style lang="scss" scoped>
  @import url('https://fonts.googleapis.com/css?family=Indie+Flower');

  * {
    font-family: Indie Flower;
  }

  .question {
    text-align: center;
    font-size: 4em;
  }

  .answer {
    font-size: 5em;

    > * {
      text-align: center;
    }

    .false {
      color: #CDDC39;
    }

    .true {
      color: #F44336;
    }
  }

  .counter {
    text-align: center;
    font-size: 0.5em;
    color: #607D8B;
  }

  .presents {
  	text-align: center;
  	padding: 40px;
  }
</style>
