from langchain_core.messages import SystemMessage, HumanMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
import fal_client, requests, os
from dotenv import load_dotenv

load_dotenv()

os.environ["FAL_KEY"] = os.getenv("FAL_KEY")
api_key = os.getenv("OPENAI_API_KEY")

lesson_tags = [
    "basic_greetings",
    "asking_for_directions",
    "ordering_food",
    "travel_transportation",
    "shopping_prices",
    "describing_people_places",
    "daily_routines",
    "talking_about_weather",
    "making_small_talk",
    "business_english",
    "job_interviews",
    "writing_emails",
    "making_appointments",
    "talking_about_hobbies",
    "expressing_opinions",
    "polite_phrases_etiquette",
    "numbers_counting",
    "telling_time",
    "common_idioms_phrases",
    "sports_recreation",
    "technology_social_media",
    "health_medical_conversations",
    "emergency_situations",
    "cultural_differences",
    "debate_argumentation",
    "describing_feelings_emotions",
    "giving_receiving_compliments",
    "making_plans_invitations",
    "storytelling_narration",
    "role_playing_real_life_situations"
]

def generate_prompt(tag):
    system_prompt = SystemMessage(f"""
        You are an assistant that generates prompts for image generation.
        You will be provided with a tag for which a prompt should be generated.
        Do not mention groups of people, max couple of people in the image.
        Do not mention any other children in the image.
        Images should be realistic, do not use word "animatedly".
                                  
        Examples:
        - tag: ordering_food
        - expected output: A customer ordering food at a restaurant counter with a friendly expression. The cashier or server listens attentively, ready to take the order. Warm lighting highlights the inviting atmosphere, with a menu board visible in the background.

        - tag: shopping_prices
        - expected output: A shopper examining an item on display in a store, comparing prices on a tag. The store is bright and well-organized, with shelves of products in the background. Soft light highlights the price tag and the shopper’s thoughtful expression.
                                  
        - tag: daily_routines
        - expected output: A person going through their daily routine, getting ready for the day. They are brushing their teeth in a bathroom with soft morning light streaming through the window. A clock on the wall shows the early hours, and everyday items like a towel and toiletries are neatly arranged.
                                  
        - tag: business_english
        - expected output: Two professionals having a discussion in a modern office setting. One is presenting a document or laptop, while the other listens attentively, taking notes. The office is sleek and well-lit, with a large window offering a city view in the background.
    
        When giving an output do not mention that it is a prompt. Just output the text.               
    """)
    human_prompt = HumanMessage(f"Tag: {tag}")
    combined_prompt = ChatPromptTemplate([system_prompt, human_prompt
    ])

    model = ChatOpenAI(api_key=api_key, temperature=0, model_name="gpt-4o-mini")
    response = model.invoke(combined_prompt.format())
    return response.content

def on_queue_update(update):
    if isinstance(update, fal_client.InProgress):
        for log in update.logs:
            print(log["message"])

def generate_image(prompt):
    result = fal_client.subscribe(
        "fal-ai/ideogram/v2",
        arguments={
            "aspect_ratio": "16:9",
            "style": "realistic",
            "prompt": prompt
        },
        with_logs=True,
        on_queue_update=on_queue_update,
    )
    return result["images"][0]["url"]

def download_image(tag, url):
    img_data = requests.get(url).content
    with open(f'lib/test/image_generator/images/{tag}.png', 'wb') as handler:
        handler.write(img_data)

lesson_tags = [
    "talking_about_hobbies",
    ]

for tag in lesson_tags:
    prompt = generate_prompt(tag)
    print(f"Tag: {tag}\nPrompt: {prompt}\n")
    url = generate_image(prompt)
    download_image(tag, url)