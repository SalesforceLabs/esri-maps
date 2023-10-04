import { LightningElement } from 'lwc';
import FOOTERICONS from '@salesforce/resourceUrl/footericons';
import GITHUB from '@salesforce/resourceUrl/github';

export default class Esri_footer extends LightningElement {
    github = GITHUB;
    facebook = FOOTERICONS+'/FooterIcons/Facebook.svg';
    twitter = FOOTERICONS+'/FooterIcons/Twitter.svg';;
}