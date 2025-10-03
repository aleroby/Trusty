export default class extends HTMLElement {
  connect() {
    const input = this.querySelector('#priceRange');
    const output = this.querySelector('#priceRangeOutput');
    if (!input || !output) return;
    const format = (v) => `$${Number(v).toLocaleString()}`;
    const update = () => { output.textContent = format(input.value); };
    input.addEventListener('input', update);
    update();
  }
}
